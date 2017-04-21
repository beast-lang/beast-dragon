module beast.backend.cpp.codebuilder;

import beast.backend.toolkit;
import std.array : Appender, appender;
import std.format : formattedWrite;
import beast.code.data.scope_.local;
import beast.code.data.var.result;
import beast.core.error.error;
import beast.code.lex.identifier;
import std.algorithm.searching : startsWith;

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
			return result_;
		}

	public: // Declaration related build commands
		override void build_localVariableDefinition( DataEntity_LocalVariable var ) {
			var.allocate( false );
			addToScope( var );

			result_ = cppIdentifier( var.memoryBlock );
			codeResult_.formattedWrite( "%s%s %s;\n", tabs, cppIdentifier( var.dataType ), result_ );
		}

		override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			try {
				const string proto = functionPrototype( func );
				declarationsResult_.formattedWrite( "%s%s;\n", tabs, proto );
				codeResult_.formattedWrite( "%s%s {\n", tabs, proto );

				labelHash_ = func.outerHash;
				pushScope( ScopeFlags.sessionRoot );

				codeResult_.formattedWrite( "%ssize_t ctimeStackBP = ctimeStackSize;\n", tabs );

				assert( !currentFunction );
				assert( !ctimeStackOffset_ );
				currentFunction = func;

				body_( this );

				// Function MUST have a return instruction (for user functions, they're added automatically when return type is void)
				codeResult_.formattedWrite( "%sfprintf( stderr, \"ERROR: Function %s did not exit via return statement\\n\" );\n", tabs, func.identificationString );
				codeResult_.formattedWrite( "%sexit( -1 );\n", tabs, func.identificationString );
				popScope( false );

				codeResult_.formattedWrite( "%s}\n\n", tabs );

				// We don't care about any compile time changes that happened - they should all be mirrored on the return; call
				trashCtimeChanges( );

				debug result_ = null;
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
					typesResult_.formattedWrite( "%sTYPEDEF( %s, %s );\n", tabs, cppIdentifier( type ), ( instanceSize + hardwareEnvironment.pointerSize - 1 ) / hardwareEnvironment.pointerSize );
				else
					typesResult_.formattedWrite( "%stypedef void %s;\n", tabs, cppIdentifier( type ) );

				debug result_ = null;
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
			mirrorCtimeChanges( );
			result_ = memoryPtrIdentifier( pointer );
		}

		override void build_offset( ExprFunction expr, size_t offset ) {
			expr( this );

			if ( offset == 0 )
				return;

			result_ = "%sOFFSET( %s, %s )".format( result_.startsWith( "CTMEM " ) ? "CTMEM " : null, result_, offset );
		}

		override void build_functionCall( Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			//codeResult_.formattedWrite( "%s// Function %s call\n", tabs, function_.tryGetIdentificationString );

			string resultVarName;
			if ( function_.returnType !is coreType.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( function_.returnType, "result" );
				build_localVariableDefinition( resultVar );
				resultVarName = "&%s".format( result_ );
			}

			codeResult_.formattedWrite( "%s{\n", tabs );

			auto _sgd = new LocalDataScope( ).scopeGuard;
			pushScope( );

			string[ ] argumentNames;
			if ( resultVarName )
				argumentNames ~= "PARAM( %s, %s )".format( resultVarName, cppIdentifier( function_.returnType ) );

			if ( function_.declarationType == Symbol.DeclType.memberFunction ) {
				assert( parentInstance );

				parentInstance.buildCode( this );
				argumentNames ~= "PARAM( %s, %s )".format( result_, cppIdentifier( parentInstance.dataType ) );
			}

			foreach ( i, ExpandedFunctionParameter param; function_.parameters ) {
				if ( param.isConstValue )
					continue;

				auto argVar = new DataEntity_TmpLocalVariable( param.dataType, "arg%s".format( i + 1 ) );
				build_localVariableDefinition( argVar );

				codeResult_.formattedWrite( "%s{\n", tabs );
				pushScope( );
				build_copyCtor( argVar, arguments[ i ] );
				popScope( );
				codeResult_.formattedWrite( "%s}\n", tabs );

				argumentNames ~= "PARAM( &%s, %s )".format( cppIdentifier( argVar.memoryBlock ), cppIdentifier( param.dataType ) );
			}

			codeResult_.formattedWrite( "%sctimeStackSize = ctimeStackBP + %s;\n", tabs, ctimeStackOffset_ );
			codeResult_.formattedWrite( "%s%s( %s );\n", tabs, cppIdentifier( function_ ), argumentNames.joiner( ", " ) );

			popScope( );

			codeResult_.formattedWrite( "%s}\n", tabs );
			result_ = resultVarName;
		}

		override void build_contextPtr( ) {
			result_ = "context";
		}

		override void build_dereference( ExprFunction arg ) {
			arg( this );
			result_ = inheritCtime( "DEREF( %s )".format( result_ ), result_ );
		}

		mixin Build_PrimitiveOperationImpl!( "cpp", "result_" );

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

			{
				condition( this );
				codeResult_.formattedWrite( "%sif( VAL( %s, bool ) ) {\n", tabs, result_ );
			}

			// Build then branch
			{
				// Branch bodies are in custom sessions to prevent changing @ctime variables outside the runtime bodies
				with ( memoryManager.session( SessionPolicy.inheritCtChangesWatcher ) ) {
					pushScope( ScopeFlags.sessionRoot );
					thenBranch( this );
					popScope( );
				}
				codeResult_.formattedWrite( "%s}\n", tabs );
			}

			// Build else branch
			if ( elseBranch ) {
				// Branch bodies are in custom sessions to prevent changing @ctime variables outside the runtime bodies
				with ( memoryManager.session( SessionPolicy.inheritCtChangesWatcher ) ) {
					codeResult_.formattedWrite( "%selse {\n", tabs );
					pushScope( ScopeFlags.sessionRoot );
					elseBranch( this );
					popScope( );
					codeResult_.formattedWrite( "%s}\n", tabs );
				}
			}

			popScope( );

			codeResult_.formattedWrite( "%s}\n", tabs );

			debug result_ = null;
		}

		override void build_loop( StmtFunction body_ ) {
			// Branch bodies are in custom sessions to prevent changing @ctime variables outside the runtime bodies
			with ( memoryManager.session( SessionPolicy.inheritCtChangesWatcher ) ) {
				pushScope( ScopeFlags.loop | ScopeFlags.sessionRoot );
				codeResult_.formattedWrite( "%swhile( true ) {\n", tabs( -1 ) );
				body_( this );
				codeResult_.formattedWrite( "%s}\n", tabs( -1 ) );
				popScope( );
			}
		}

		override void build_break( size_t scopeIndex ) {
			foreach_reverse ( ref s; scopeStack_[ scopeIndex .. $ ] )
				generateScopeExit( s );

			additionalScopeData_[ scopeIndex ].requiresEndLabelConstruction = true;
			codeResult_.formattedWrite( "%sgoto elbl_%s;\n", tabs, additionalScopeData_[ scopeIndex ].hash.str );
		}

		override void build_return( DataEntity returnValue ) {
			assert( currentFunction );

			if ( returnValue ) {
				auto resultVar = new DataEntity_Result( currentFunction, false, returnValue.dataType );
				build_copyCtor( resultVar, returnValue );
			}

			generateScopesExit( );
			mirrorCtimeChanges( );
			codeResult_.formattedWrite( "%sreturn;\n", tabs );

			debug result_ = null;
		}

	protected:
		string functionPrototype( Symbol_RuntimeFunction func ) {
			size_t parameterCount = 0;
			auto result = appender!string;
			result.formattedWrite( "void %s( ", cppIdentifier( func ) ); // Return value is passed as a pointer
			if ( func.returnType !is coreType.Void ) {
				result.formattedWrite( "%s *result", cppIdentifier( func.returnType ) );
				parameterCount++;
			}

			if ( func.declarationType == Symbol.DeclType.memberFunction ) {
				if ( parameterCount )
					result ~= ", ";

				result.formattedWrite( "%s *context", cppIdentifier( func.contextType ) );
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
		static string cppIdentifier( Symbol sym ) {
			return "_%s_%s".format( sym.outerHash.str, sym.identifier ? safeIdentifier( sym.identifier.str ) : "tmp" );
		}

		/// Cpp identifier for a parameter
		static string cppParamIdentifier( size_t index, Identifier id ) {
			return "_p%s_%s".format( index, safeIdentifier( id.str ) );
		}

		static string cppIdentifier( MemoryBlock block, bool addrOf = false ) {
			if ( block.flag( MemoryBlock.Flag.functionParameter ) )
				return cppParamIdentifier( block.relatedDataEntity.asFunctionParameter_index, block.relatedDataEntity.identifier );

			if ( block.flag( MemoryBlock.Flag.result ) )
				return "result";

			else if ( block.isCtime && !block.isStatic && block.session == context.session )
				return "%sctimeStack[ ctimeStackBP + %s ]".format( addrOf ? "" : "*", block.bpOffset );

			else if ( block.identifier )
				return "%s_%#x_%s".format( addrOf ? "&" : "", block.startPtr.val, safeIdentifier( block.identifier ) );

			else if ( block.relatedDataEntity )
				return "%s_%s_%s".format( addrOf ? "&" : "", block.relatedDataEntity.outerHash.str, block.relatedDataEntity.identifier ? block.relatedDataEntity.identifier.str : "tmp" );

			else
				return "%s_%#x".format( addrOf ? "&" : "", block.startPtr.val );
		}

		static string blockDesc( MemoryBlock block ) {
			if ( block.identifier )
				return "%s %s".format( block.startPtr, safeIdentifier( block.identifier ) );

			else if ( block.relatedDataEntity )
				return "%s %s".format( block.startPtr, block.relatedDataEntity.identifier ? block.relatedDataEntity.identifier.str : "tmp" );

			else
				return "%s tmp".format( block.startPtr );
		}

		static string safeIdentifier( string id ) {
			import std.array : replace;

			return id.replace( "#", "_" );
		}

		static string memoryPtrIdentifier( MemoryPtr ptr ) {
			if ( ptr.isNull )
				return "CTMEM 0";

			MemoryBlock block = ptr.block;
			block.markReferenced( );

			string result;
			if ( block.startPtr == ptr )
				return "%s%s".format( block.isRuntime ? null : "CTMEM ", cppIdentifier( block, true ) );
			else
				return "%sOFFSET( %s, %s )".format( block.isRuntime ? null : "CTMEM ", cppIdentifier( block, true ), ptr.val - block.startPtr.val );
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

			additionalScopeData_ ~= AdditionalScopeData( labelHash_, false );
		}

		override void popScope( bool generateDestructors = true ) {
			// Result might be f-ked around because of destructors
			auto result = result_;

			super.popScope( generateDestructors );

			if ( additionalScopeData_[ $ - 1 ].requiresEndLabelConstruction )
				codeResult_.formattedWrite( "elbl_%s:\n", additionalScopeData_[ $ - 1 ].hash.str );

			additionalScopeData_.length--;
			tabOffset_--;

			result_ = result;
		}

	protected:
		override void mirrorBlockAllocation( MemoryBlock block ) {
			debug assert( block.session == context.session );

			assert( !block.bpOffset );
			block.bpOffset = ctimeStackOffset_;
			codeResult_.formattedWrite( "%s// alloc %s\n", tabs, blockDesc( block ) );
			codeResult_.formattedWrite( "%s%s = (uintptr_t*) malloc( %s );\n", tabs, cppIdentifier( block, true ), block.size );
			ctimeStackOffset_++;
		}

		override void mirrorBlockDataChange( MemoryBlock block ) {
			debug assert( block.session == context.session );

			immutable string id = cppIdentifier( block, true );

			codeResult_.formattedWrite( "%s{\n", tabs );
			codeResult_.formattedWrite( "%s// update %s\n", tabs( 1 ), blockDesc( block ) );
			codeResult_.formattedWrite( "%sstatic uint8_t _ctData[ %s ] = { %s };\n", tabs( 1 ), block.size, block.data[ 0 .. block.size ].map!( x => "%#x".format( x ) ).joiner( ", " ) );
			codeResult_.formattedWrite( "%smemcpy( %s, _ctData, %s );\n", tabs( 1 ), id, block.size );

			// Update pointers
			foreach ( ptr; memoryManager.pointersInSessionBlock( block ) ) {
				assert( ptr.val >= block.startPtr.val && ptr.val <= block.endPtr.val - hardwareEnvironment.pointerSize );
				codeResult_.formattedWrite( "%sVAL( %s, void* ) = %s;\n", tabs( 1 ), memoryPtrIdentifier( ptr ), memoryPtrIdentifier( ptr.readMemoryPtr ) );
			}

			codeResult_.formattedWrite( "%s}\n", tabs );
		}

		override void mirrorBlockDeallocation( MemoryBlock block ) {
			debug assert( block.session == context.session );

			codeResult_.formattedWrite( "%s// free %s\n", tabs, blockDesc( block ) );
			codeResult_.formattedWrite( "%sfree( %s );\n", tabs, cppIdentifier( block, true ) );
		}

	package:
		pragma( inline ) static void enforceOperandNotCtime( string op ) {
			benforce( !isOperandCtime( op ), E.protectedMemory, "Cannot write to a @ctime variable in runtime" );
		}

		pragma( inline ) static bool isOperandCtime( string op ) {
			import std.algorithm : startsWith;

			return op.startsWith( "CTMEM " );
		}

		pragma( inline ) static string inheritCtime( string op, string sourceOp ) {
			return isOperandCtime( sourceOp ) ? "CTMEM " ~ op : op;
		}

	package:
		Hash hash_; /// Increments every time a child codegen is created -- because of hashing
		size_t childrenCounter_; /// Increments every time a new hash is needed
		size_t hashCounter_;
		Appender!string codeResult_, declarationsResult_, typesResult_; /// Identifier of a variable representing result of last build expression
		size_t tabOffset_; /// Accumulator for optimized tabs output
		string tabsString_;
		size_t ctimeStackOffset_;

	package:
		/// Variable name representing last build expression
		string result_;

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
