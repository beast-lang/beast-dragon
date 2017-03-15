module beast.backend.cpp.codebuilder;

import beast.backend.toolkit;
import std.array : Appender, appender;
import std.format : formattedWrite;
import beast.code.data.scope_.local;

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

			body_( this );

			popScope( );

			codeResult_.formattedWrite( "%s}\n\n", tabs );

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

		override void build_memoryWrite( DataScope scope_, MemoryPtr target, DataEntity data ) {
			data.buildCode( this, scope_ );
			const string rightOp = resultVarName_;

			build_memoryAccess( target );
			codeResult_.formattedWrite( "%smemcpy( %s, %s, %s );\n", tabs, resultVarName_, rightOp, data.dataType.instanceSize );
		}

		override void build_functionCall( DataScope scope_, Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			string resultVarName;
			if ( function_.returnType !is coreLibrary.type.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( function_.returnType, scope_, false );
				build_localVariableDefinition( resultVar );
				resultVarName = cppIdentifier( resultVar );
			}

			codeResult_.formattedWrite( "%s{\n", tabs );

			auto subScope = scoped!LocalDataScope( scope_ );
			pushScope( );

			string[ ] argumentNames;
			if ( resultVarName )
				argumentNames ~= "&" ~ resultVarName;

			if ( function_.declarationType == Symbol.DeclType.memberFunction ) {
				assert( parentInstance );

				parentInstance.buildCode( this, subScope );
				argumentNames ~= "&" ~ resultVarName_;
			}

			foreach ( i, ExpandedFunctionParameter param; function_.parameters ) {
				if ( param.isConstValue )
					continue;

				auto argVar = new DataEntity_TmpLocalVariable( param.dataType, subScope, false );
				build_localVariableDefinition( argVar );
				build_copyCtor( argVar, arguments[ i ], subScope );

				argumentNames ~= "&" ~ cppIdentifier( argVar );
			}

			codeResult_.formattedWrite( "%s%s( %s );\n", tabs, cppIdentifier( function_ ), argumentNames.joiner( ", " ) );

			popScope( );
			subScope.finish( );

			codeResult_.formattedWrite( "%s}\n", tabs );
			resultVarName_ = resultVarName;
		}

		override void build_primitiveOperation( DataScope scope_, Symbol_RuntimeFunction wrapperFunction, BackendPrimitiveOperation op, DataEntity parentInstance, DataEntity[ ] arguments ) {
			static import beast.backend.cpp.primitiveop;

			debug resultVarName_ = null;

			if ( wrapperFunction.returnType !is coreLibrary.type.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( wrapperFunction.returnType, scope_, false );
				build_localVariableDefinition( resultVar );
				resultVarName_ = cppIdentifier( resultVar );
			}

			codeResult_.formattedWrite( "%s{\n", tabs );
			auto subScope = scoped!LocalDataScope( scope_ );
			pushScope( );

			pragma( inline ) static opFunc( string opStr, BackendPrimitiveOperation op )( DataScope scope_, CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
				static if ( __traits( hasMember, beast.backend.cpp.primitiveop, "primitiveOp_%s".format( opStr ) ) )
					mixin( "beast.backend.cpp.primitiveop.primitiveOp_%s( scope_, cb, inst, args );".format( opStr ) );
				else
					assert( 0, "primitiveOp %s is not implemented for %s".format( opStr, cb.identificationString ) );
			}

			mixin(  //
					"final switch( op ) {\n%s\n}".format(  //
					[ __traits( derivedMembers, BackendPrimitiveOperation ) ].map!(  //
					x => "case BackendPrimitiveOperation.%s: opFunc!( \"%s\", BackendPrimitiveOperation.%s )( subScope, this, parentInstance, arguments ); break;\n".format( x, x, x ) //
					 ).joiner ) );

			popScope( );
			subScope.finish( );
			codeResult_.formattedWrite( "%s}\n", tabs );
		}

	public: // Statement related build commands
		override void build_if( DataScope scope_, DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			codeResult_.formattedWrite( "%s{\n", tabs );
			pushScope( );
			auto subScope = scoped!LocalDataScope( scope_ ); // Build the condition
			{
				condition.buildCode( this, subScope );
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
			subScope.finish( );
			codeResult_.formattedWrite( "%s}\n", tabs );
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
			return "_%s__%s".format( var.outerHash.str, var.identifier ? safeIdentifier( var.identifier.str ) : "tmp" );
		}

		static string cppIdentifier( Symbol sym ) {
			return "_%s__%s".format( sym.outerHash.str, sym.identifier ? safeIdentifier( sym.identifier.str ) : "tmp" );
		}

		static string cppIdentifier( ExpandedFunctionParameter param ) {
			return "_%s__%s".format( param.outerHash.str, safeIdentifier( param.identifier.str ) );
		}

		static string cppIdentifier( MemoryBlock block, bool addrOf = false ) {
			string addrOfStr = addrOf ? "&" : "";
			if ( block.isFunctionParameter ) {
				return cppIdentifier( block.functionParameter );
			}
			else if ( block.isLocal ) {
				assert( block.localVariable );
				return addrOfStr ~ cppIdentifier( block.localVariable );
			}
			else if ( block.identifier )
				return "%s__s%s_%s".format( addrOfStr, block.startPtr.val, safeIdentifier( block.identifier ) );
			else
				return "%s__s%s".format( addrOfStr, block.startPtr.val );
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

		override void popScope( ) {
			foreach ( var; scopeItems )
				codeResult_.formattedWrite( "%s// #dtor %s\n", tabs, cppIdentifier( var ) );
			super.popScope( );
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
}
