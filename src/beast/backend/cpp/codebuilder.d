module beast.backend.cpp.codebuilder;

import beast.backend.toolkit;
import std.array : Appender, appender;
import std.format : formattedWrite;
import beast.code.data.scope_.local;
import beast.code.data.var.result;

// TODO: Asynchronous proxy definition handler

class CodeBuilder_Cpp : CodeBuilder {
	public enum tab = "\t";

	public:
		this( CodeBuilder_Cpp parent ) {
			tabsString_ = tab ~ tab ~ tab ~ tab;

			codeResult_ = appender!string;
			declarationsResult_ = appender!string;
			typesResult_ = appender!string;

			if ( parent ) {
				tabOffset_ = parent.tabOffset_ + 1;
				hash_ = parent.hash_ + Hash( parent.childrenCounter_++ );
			}
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
		override void build_moduleDefinition( Symbol_Module module_, DeclFunction content ) {
			const string str = "\n%s// module %s\n".format( tabs, module_.identificationString );
			declarationsResult_ ~= str;
			typesResult_ ~= str;
			codeResult_ ~= str;
			content( this );

			debug resultVarName_ = null;
		}

		override void build_localVariableDefinition( DataEntity_LocalVariable var ) {
			addToScope( var );

			resultVarName_ = cppIdentifier( var );
			codeResult_.formattedWrite( "%s%s %s;\n", tabs, cppIdentifier( var.dataType ), resultVarName_ );
		}

		override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			const string proto = functionPrototype( func );
			declarationsResult_.formattedWrite( "%s%s;\n", tabs, proto );
			codeResult_.formattedWrite( "%s%s {\n", tabs, proto );

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

		override void build_typeDefinition( Symbol_Type type, DeclFunction content ) {
			if ( auto instanceSize = type.instanceSize )
				typesResult_.formattedWrite( "%stypedef unsigned char %s[ %s ];\n", tabs, cppIdentifier( type ), instanceSize );
			else
				typesResult_.formattedWrite( "%stypedef void %s;\n", tabs, cppIdentifier( type ) );

			debug resultVarName_ = null;

			content( this );
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

			build_memoryAccess( target );
			codeResult_.formattedWrite( "%smemcpy( %s, %s, %s );\n", tabs, resultVarName_, rightOp, data.dataType.instanceSize );
		}

		override void build_functionCall( Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
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
				argumentNames ~= "&" ~ resultVarName_;
			}

			foreach ( i, ExpandedFunctionParameter param; function_.parameters ) {
				if ( param.isConstValue )
					continue;

				auto argVar = new DataEntity_TmpLocalVariable( param.dataType, false, "arg%s".format( i + 1 ) );
				build_localVariableDefinition( argVar );
				build_copyCtor( argVar, arguments[ i ] );

				argumentNames ~= "&" ~ cppIdentifier( argVar );
			}

			codeResult_.formattedWrite( "%s%s( %s );\n", tabs, cppIdentifier( function_ ), argumentNames.joiner( ", " ) );

			popScope( );
			_s.finish( );

			codeResult_.formattedWrite( "%s}\n", tabs );
			resultVarName_ = resultVarName;
		}

		override void build_primitiveOperation( Symbol_RuntimeFunction wrapperFunction, BackendPrimitiveOperation op, DataEntity parentInstance, DataEntity[ ] arguments ) {
			static import beast.backend.cpp.primitiveop;

			debug resultVarName_ = null;

			if ( wrapperFunction.returnType !is coreLibrary.type.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( wrapperFunction.returnType, false, "result" );
				build_localVariableDefinition( resultVar );
			}

			codeResult_.formattedWrite( "%s{\n", tabs );

			auto _s = scoped!LocalDataScope( );
			auto _sgd = _s.scopeGuard;
			pushScope( );

			mixin( ( ) { //
				auto result = appender!string;
				result ~= "final switch( op ) {\n";

				foreach ( opStr; __traits( derivedMembers, BackendPrimitiveOperation ) ) {
					result ~= "case BackendPrimitiveOperation.%s:\n".format( opStr );

					static if ( __traits( hasMember, beast.backend.cpp.primitiveop, "primitiveOp_%s".format( opStr ) ) )
						result ~= "beast.backend.cpp.primitiveop.primitiveOp_%s( this, parentInstance, arguments );\nbreak;\n".format( opStr );
					else
						result ~= "assert( 0, \"primitiveOp %s is not implemented for codebuilder.cpp\" );\n".format( opStr );
				}

				result ~= "}\n";
				return result.data;
			}( ) );

			popScope( );
			_s.finish( );

			codeResult_.formattedWrite( "%s}\n", tabs );
		}

	public: // Statement related build commands
		override void build_if( DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			codeResult_.formattedWrite( "%s{\n", tabs );
			pushScope( );

			auto _s = scoped!LocalDataScope( );
			auto _sgd = _s.scopeGuard; // Build the condition

			{
				condition.buildCode( this );
				codeResult_.formattedWrite( "%sif( %s ) {\n", tabs, resultVarName_ );
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
				result.formattedWrite( "%s *context", cppIdentifier( func.dataEntity.parent.dataType ) );
				parameterCount++;
			}

			foreach ( param; func.parameters ) {
				// Constant-value parameters do not go to the output code
				if ( param.isConstValue )
					continue;
				if ( parameterCount )
					result ~= ", ";
				result.formattedWrite( "%s *%s", cppIdentifier( param.dataType ), cppIdentifier( param ) );
				parameterCount++;
			}

			if ( parameterCount )
				result ~= " ";
			result ~= ")";
			return result.data;
		}

	public:
		static string cppIdentifier( DataEntity_LocalVariable var ) {
			return "_%s__%s".format( var.outerHash.str, var.identifier ? safeIdentifier( var.identifier.str ) : var.memoryBlock.identifier ? safeIdentifier( var.memoryBlock.identifier ) : "tmp" );
		}

		static string cppIdentifier( Symbol sym ) {
			return "_%s__%s".format( sym.outerHash.str, sym.identifier ? safeIdentifier( sym.identifier.str ) : "tmp" );
		}

		static string cppIdentifier( ExpandedFunctionParameter param ) {
			return "_%s__%s".format( param.outerHash.str, safeIdentifier( param.identifier.str ) );
		}

		static string cppIdentifier( MemoryBlock block, bool addrOf = false ) {
			string addrOfStr = addrOf ? "&" : "";
			if ( block.isFunctionParameter )
				return cppIdentifier( block.functionParameter );

			else if ( block.flags & MemoryBlock.Flag.result )
				return "result";

			else if ( block.isLocal ) {
				assert( block.localVariable );
				return addrOfStr ~ cppIdentifier( block.localVariable );
			}

			else if ( block.identifier )
				return "%s__%#x_%s".format( addrOfStr, block.startPtr.val, safeIdentifier( block.identifier ) );

			else
				return "%s__%#x".format( addrOfStr, block.startPtr.val );
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
		override void pushScope( ) {
			tabOffset_++;
			super.pushScope( );
		}

		override void popScope( bool generateDestructors = true ) {
			super.popScope( generateDestructors );
			tabOffset_--;
		}

	package:
		Hash hash_; /// Increments every time a child codegen is created -- because of hashing
		size_t childrenCounter_; /// Increments every time a new hash is needed
		size_t hashCounter_;
		Appender!string codeResult_, declarationsResult_, typesResult_; /// Identifier of a variable representing result of last build expression
		string resultVarName_;
		size_t tabOffset_; /// Accumulator for optimized tabs output
		string tabsString_;

	private:
		Symbol_RuntimeFunction currentFunction;

}
