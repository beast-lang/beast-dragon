module beast.backend.cpp.codebuilder;

import beast.backend.toolkit;
import beast.code.data.function_.expandedparameter;
import std.format;

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
			// TODO: implicit value
			resultVarName_ = cppIdentifier( var );
			codeResult_.formattedWrite( "%s%s %s;\n", tabs, cppIdentifier( var.dataType ), resultVarName_ );
		}

		override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			const string proto = functionPrototype( func );
			declarationsResult_.formattedWrite( "%s%s;\n", tabs, proto );
			codeResult_.formattedWrite( "%s%s {\n", tabs, proto );
			tabOffset_++;

			body_( this );

			tabOffset_--;
			codeResult_.formattedWrite( "%s}\n\n", tabs );

			debug resultVarName_ = null;
		}

		override void build_typeDefinition( Symbol_Type type ) {
			if ( auto instanceSize = type.instanceSize )
				typesResult_.formattedWrite( "%stypedef unsigned char %s[ %s ];\n", tabs, cppIdentifier( type ), instanceSize );
			else
				typesResult_.formattedWrite( "%stypedef void %s;\n", tabs, cppIdentifier( type ) );

			debug resultVarName_ = null;
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

		override void build_functionCall( DataScope scope_, Symbol_RuntimeFunction function_, DataEntity[ ] arguments ) {
			string resultVarName;
			if ( function_.returnType !is coreLibrary.types.Void ) {
				resultVarName = "_%s_tmp".format( getHash( ) );
				codeResult_.formattedWrite( "%s%s %s;\n", tabs, cppIdentifier( function_.returnType ), resultVarName );
			}

			codeResult_.formattedWrite( "%s{\n", tabs );
			tabOffset_++;

			string[ ] argumentNames;
			if ( resultVarName )
				argumentNames ~= "&" ~ resultVarName;

			foreach ( arg; arguments ) {
				arg.buildCode( this, scope_ );
				argumentNames ~= resultVarName_;
			}

			codeResult_.formattedWrite( "%s%s( %s );\n", tabs, cppIdentifier( function_ ), argumentNames.joiner( ", " ) );

			tabOffset_--;
			codeResult_.formattedWrite( "%s}\n", tabs );
			resultVarName_ = resultVarName;
		}

	public: // Statement related build commands
		override void build_if( DataScope scope_, DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			codeResult_ ~= tabs ~ "{\n";
			tabOffset_++;

			// Build the condition
			{
				condition.buildCode( this, scope_ );
				codeResult_.formattedWrite( "%sif( %s ) {\n", tabs, resultVarName_ );
			}

			// Build then branch
			{
				tabOffset_++;
				thenBranch( this );
				tabOffset_--;

				codeResult_.formattedWrite( "%s}\n", tabs );
			}

			// Build else branch
			if ( elseBranch ) {
				codeResult_.formattedWrite( "%selse {\n", tabs );

				tabOffset_++;
				elseBranch( this );
				tabOffset_--;

				codeResult_.formattedWrite( "%s}\n", tabs );
			}

			tabOffset_--;
			codeResult_.formattedWrite( "%s}\n", tabs );

			debug resultVarName_ = null;
		}

	protected:
		string functionPrototype( Symbol_RuntimeFunction func ) {
			size_t parameterCount = 0;
			auto result = appender!string;
			result.formattedWrite( "void %s( ", cppIdentifier( func ) );

			// Return value is passed as a pointer
			if ( func.returnType !is coreLibrary.types.Void ) {
				result.formattedWrite( "%s *result", cppIdentifier( func.returnType ) );
				parameterCount++;
			}

			foreach ( param; func.parameters ) {
				// Constant-value parameters do not go to the output code
				if ( param.constValue )
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
			return id.replace( "#", "_" );
		}

	protected:
		final string tabs( ) {
			while ( tabsString_.length < tabOffset_ * tab.length )
				tabsString_ ~= tabsString_;

			return tabsString_[ 0 .. tabOffset_ * tab.length ];
		}

		final string getHash( ) {
			return ( hash_ + Hash( hashCounter_++ ) ).str;
		}

	protected:
		Hash hash_;
		/// Increments every time a child codegen is created -- because of hashing
		size_t childrenCounter_;
		/// Increments every time a new hash is needed
		size_t hashCounter_;
		Appender!string codeResult_, declarationsResult_, typesResult_;
		string resultVarName_;
		size_t tabOffset_;
		/// Accumulator for optimized tabs output
		string tabsString_;

}
