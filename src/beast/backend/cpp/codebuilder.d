module beast.backend.cpp.codebuilder;

import beast.backend.toolkit;
import std.array : Appender, appender;
import std.format : formattedWrite;
import beast.code.data.scope_.local;
import beast.code.data.var.result;
import beast.core.error.error;
import beast.code.lex.identifier;

// TODO: Asynchronous proxy definition handler

class CodeBuilder_Cpp : CodeBuilder {
	public enum tab = "\t";

	public:
		this( size_t tabOffset = 0 ) {
			tabsString_ = tab ~ tab ~ tab ~ tab;
			tabOffset_ = tabOffset;

			codeResult_ = appender!string;
			declarationsResult_ = appender!string;
			typesResult_ = appender!string;
		}

	public:
		override bool isCtime( ) {
			return true;
		}

	public:
		string code_types( ) {
			return typesResult_.data;
		}

		string code_declarations( ) {
			return declarationsResult_.data;
		}

		string code_implementations( ) {
			return codeResult_.data;
		}

		/// When building an expression, result of the expression is stored into given variable
		string resultVarName( ) {
			return resultVarName_;
		}

	public: // Declaration related build commands
		override void build_localVariableDefinition( DataEntity_LocalVariable var ) {
			addToScope( var );

			resultVarName_ = cppIdentifier( var );
			codeResult_.formattedWrite( "%s%s %s;\n", tabs, cppIdentifier( var.dataType ), resultVarName_ );
		}

		override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			try {
				const string proto = functionPrototype( func );
				declarationsResult_.formattedWrite( "%s%s;\n", tabs, proto );
				codeResult_.formattedWrite( "%s%s {\n", tabs, proto );

				labelHash_ = func.outerHash;
				pushScope( );

				auto prevFunc = currentFunction;
				currentFunction = func;

				body_( this );

				// Function MUST have a return instruction (for user functions, they're added automatically when return type is void)
				codeResult_.formattedWrite( "%sfprintf( stderr, \"ERROR: Function %s did not exit via return statement\\n\" );\n", tabs, func.identificationString );
				codeResult_.formattedWrite( "%sexit( -1 );\n", tabs, func.identificationString );
				popScope( false );

				codeResult_.formattedWrite( "%s}\n\n", tabs );

				currentFunction = prevFunc;

				debug resultVarName_ = null;
			}
			catch ( BeastErrorException exc ) {
				string errStr = "\n// ERROR BUILDING %s\n".format( func.tryGetIdentificationString );
				codeResult_ ~= errStr;
				typesResult_ ~= errStr;
				declarationsResult_ ~= errStr;
			}
		}

		override void build_typeDefinition( Symbol_Type type ) {
			try {
				if ( auto instanceSize = type.instanceSize )
					typesResult_.formattedWrite( "%stypedef unsigned char %s[ %s ];\n", tabs, cppIdentifier( type ), instanceSize );
				else
					typesResult_.formattedWrite( "%stypedef void %s;\n", tabs, cppIdentifier( type ) );

				debug resultVarName_ = null;
			}
			catch ( BeastErrorException exc ) {
				string errStr = "\n// ERROR BUILDING %s\n".format( type.tryGetIdentificationString );
				codeResult_ ~= errStr;
				typesResult_ ~= errStr;
				declarationsResult_ ~= errStr;
			}
		}

	public: // Expression related build commands
		override void build_memoryAccess( MemoryPtr pointer ) {
			MemoryBlock block = pointer.block;
			block.markReferenced( );

			if ( block.startPtr == pointer )
				resultVarName_ = cppIdentifier( block, true );
			else
				resultVarName_ = "( %s + %s )".format( cppIdentifier( block, true ), pointer - block.startPtr );
		}

		override void build_memoryWrite( MemoryPtr target, DataEntity data ) {
			data.buildCode( this );
			const string rightOp = resultVarName_;

			MemoryBlock block = target.block;
			block.markReferenced( );

			benforce( block.isRuntime, E.protectedMemory, "Cannot write to ctime variable at runtime" );

			string var;
			if ( block.startPtr == target )
				var = cppIdentifier( block, true );
			else
				var = "( %s + %s )".format( cppIdentifier( block, true ), target - block.startPtr );

			codeResult_.formattedWrite( "%smemcpy( %s, %s, %s );\n", tabs, var, rightOp, data.dataType.instanceSize );
		}

		override void build_functionCall( Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			//codeResult_.formattedWrite( "%s// Function %s call\n", tabs, function_.tryGetIdentificationString );

			string resultVarName;
			if ( function_.returnType !is coreLibrary.type.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( function_.returnType, false, "result" );
				build_localVariableDefinition( resultVar );
				resultVarName = resultVarName_;
			}

			codeResult_.formattedWrite( "%s{\n", tabs );

			auto _s = scoped!LocalDataScope( );
			auto _sgd = _s.scopeGuard;
			pushScope( );

			string[ ] argumentNames;
			if ( resultVarName )
				argumentNames ~= "&" ~ resultVarName;

			if ( function_.declarationType == Symbol.DeclType.memberFunction ) {
				assert( parentInstance );

				parentInstance.buildCode( this );
				argumentNames ~= resultVarName_;
			}

			foreach ( i, ExpandedFunctionParameter param; function_.parameters ) {
				if ( param.isConstValue )
					continue;

				auto argVar = new DataEntity_TmpLocalVariable( param.dataType, false, "arg%s".format( i + 1 ) );
				build_localVariableDefinition( argVar );

				codeResult_.formattedWrite( "%s{\n", tabs );
				pushScope( );
				build_copyCtor( argVar, arguments[ i ] );
				popScope( );
				codeResult_.formattedWrite( "%s}\n", tabs );

				argumentNames ~= "&" ~ cppIdentifier( argVar );
			}

			codeResult_.formattedWrite( "%s%s( %s );\n", tabs, cppIdentifier( function_ ), argumentNames.joiner( ", " ) );

			popScope( );
			_s.finish( );

			codeResult_.formattedWrite( "%s}\n", tabs );
			resultVarName_ = resultVarName;
		}

		mixin Build_PrimitiveOperationImpl!( "cpp", "resultVarName_" );

	public: // Statement related build commands
		override void build_scope( StmtFunction body_ ) {
			codeResult_.formattedWrite( "%s{\n", tabs );
			pushScope( );
			body_( this );
			popScope( );
			codeResult_.formattedWrite( "%s}\n", tabs );
		}

		override void build_if( ExprFunction condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			codeResult_.formattedWrite( "%s{\n", tabs );
			pushScope( );

			auto _s = scoped!LocalDataScope( );
			auto _sgd = _s.scopeGuard; // Build the condition

			{
				condition( this );
				codeResult_.formattedWrite( "%sif( VAL( %s, bool ) ) {\n", tabs, resultVarName_ );
			}

			// Build then branch
			{
				pushScope( );
				thenBranch( this );
				popScope( );
				codeResult_.formattedWrite( "%s}\n", tabs );
			}

			// Build else branch
			if ( elseBranch ) {
				codeResult_.formattedWrite( "%selse {\n", tabs );
				pushScope( );
				elseBranch( this );
				popScope( );
				codeResult_.formattedWrite( "%s}\n", tabs );
			}

			popScope( );
			_s.finish( );

			codeResult_.formattedWrite( "%s}\n", tabs );

			debug resultVarName_ = null;
		}

		override void build_loop( StmtFunction body_ ) {
			pushScope( ScopeFlags.loop );
			codeResult_.formattedWrite( "%swhile( true ) {\n", tabs( -1 ) );
			body_( this );
			codeResult_.formattedWrite( "%s}\n", tabs( -1 ) );
			popScope( );
		}

		override void build_break( size_t scopeIndex ) {
			foreach_reverse ( ref s; scopeStack_[ scopeIndex .. $ ] )
				generateScopeExit( s );

			additionalScopeData_[ scopeIndex ].requiresEndLabelConstruction = true;
			codeResult_.formattedWrite( "%sgoto elbl_%s;\n", tabs, additionalScopeData_[ scopeIndex ].hash.str );
		}

		override void build_return( DataEntity returnValue ) {
			assert( currentFunction );

			if ( returnValue )
				build_copyCtor( new DataEntity_Result( currentFunction, returnValue.dataType ), returnValue );

			generateScopesExit( );
			codeResult_.formattedWrite( "%sreturn;\n", tabs );

			debug resultVarName_ = null;
		}

	protected:
		string functionPrototype( Symbol_RuntimeFunction func ) {
			size_t parameterCount = 0;
			auto result = appender!string;
			result.formattedWrite( "void %s( ", cppIdentifier( func ) ); // Return value is passed as a pointer
			if ( func.returnType !is coreLibrary.type.Void ) {
				result.formattedWrite( "%s *result", cppIdentifier( func.returnType ) );
				parameterCount++;
			}

			if ( func.declarationType == Symbol.DeclType.memberFunction ) {
				if ( parameterCount )
					result ~= ", ";

				result.formattedWrite( "%s *context", cppIdentifier( func.dataEntity.parent.ctExec.readType ) );
				parameterCount++;
			}

			foreach ( param; func.parameters ) {
				// Constant-value parameters do not go to the output code
				if ( param.isConstValue )
					continue;
				if ( parameterCount )
					result ~= ", ";
				result.formattedWrite( "%s *%s", cppIdentifier( param.dataType ), cppParamIdentifier( param.index, param.identifier ) );
				parameterCount++;
			}

			if ( parameterCount )
				result ~= " ";
			result ~= ")";
			return result.data;
		}

	public:
		static string cppIdentifier( DataEntity_LocalVariable var ) {
			return "_%s_%s".format( var.outerHash.str, var.identifier ? safeIdentifier( var.identifier.str ) : "tmp" );
		}

		static string cppIdentifier( Symbol sym ) {
			return "_%s_%s".format( sym.outerHash.str, sym.identifier ? safeIdentifier( sym.identifier.str ) : "tmp" );
		}

		static string cppIdentifier( DataEntity e ) {
			if ( e.identifier )
				return "_%s_%s".format( e.outerHash.str, safeIdentifier( e.identifier.str ) );
			else
				return "_%s_tmp".format( e.outerHash.str );
		}

		static string cppParamIdentifier( size_t index, Identifier id ) {
			return "_p%s_%s".format( index, safeIdentifier( id.str ) );
		}

		static string cppIdentifier( MemoryBlock block, bool addrOf = false ) {
			string addrOfStr = addrOf ? "&" : "";

			if ( block.flag( MemoryBlock.Flag.functionParameter ) )
				return cppParamIdentifier( block.relatedDataEntity.asFunctionParameter_index, block.relatedDataEntity.identifier );

			if ( block.flag( MemoryBlock.Flag.result ) )
				return "result";

			else if ( block.flag( MemoryBlock.Flag.contextPtr ) )
				return "context";

			else if ( block.identifier )
				return "%s_%#x_%s".format( addrOfStr, block.startPtr.val, safeIdentifier( block.identifier ) );

			else if ( block.relatedDataEntity )
				return addrOfStr ~ cppIdentifier( block.relatedDataEntity );

			else
				return "%s_%#x".format( addrOfStr, block.startPtr.val );
		}

		static string safeIdentifier( string id ) {
			import std.array : replace;

			return id.replace( "#", "_" );
		}

	public:
		final string identificationString( ) {
			return "codebuilder.c++";
		}

	package:
		final string tabs( int inc = 0 ) {
			while ( tabsString_.length < ( tabOffset_ + inc ) * tab.length )
				tabsString_ ~= tabsString_;

			return tabsString_[ 0 .. ( tabOffset_ + inc ) * tab.length ];
		}

		final string getHash( ) {
			return ( hash_ + Hash( hashCounter_++ ) ).str;
		}

	public:
		override void pushScope( ScopeFlags flags = ScopeFlags.none ) {
			tabOffset_++;
			labelHash_ += Hash( 1 );

			super.pushScope( flags );
			if ( flags & ScopeFlags.continuable )
				codeResult_.formattedWrite( "slbl_%s:\n", labelHash_.str );

			additionalScopeData_ ~= AdditionalScopeData( labelHash_ );
		}

		override void popScope( bool generateDestructors = true ) {
			// Result might be f-ked around because of destructors
			auto result = resultVarName_;

			super.popScope( generateDestructors );

			if ( additionalScopeData_[ $ - 1 ].requiresEndLabelConstruction )
				codeResult_.formattedWrite( "elbl_%s:\n", additionalScopeData_[ $ - 1 ].hash.str );

			additionalScopeData_.length--;
			tabOffset_--;

			resultVarName_ = result;
		}

	package:
		Hash hash_; /// Increments every time a child codegen is created -- because of hashing
		size_t childrenCounter_; /// Increments every time a new hash is needed
		size_t hashCounter_;
		Appender!string codeResult_, declarationsResult_, typesResult_; /// Identifier of a variable representing result of last build expression
		size_t tabOffset_; /// Accumulator for optimized tabs output
		string tabsString_;

	package:
		/// Variable name representing last build expression
		string resultVarName_;

	private:
		Symbol_RuntimeFunction currentFunction;
		AdditionalScopeData[ ] additionalScopeData_ = [ AdditionalScopeData( ) ];
		/// Outer hash used for creating labels (stolen from current function/type)
		Hash labelHash_;

	private:
		struct AdditionalScopeData {
			Hash hash;
			bool requiresEndLabelConstruction;
		}

}
