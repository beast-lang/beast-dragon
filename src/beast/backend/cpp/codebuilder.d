module beast.backend.cpp.codebuilder;

import beast.backend.toolkit;

// TODO: Asynchronous proxy definition handler

final class CodeBuilder_Cpp : CodeBuilder {

public:
	this( CodeBuilder_Cpp parent ) {
		result_ = appender!string;

		if ( parent )
			tabOffset_ = parent.tabOffset_ + 1;
	}

public:
	/// Last built code
	string result( ) {
		return result_.data;
	}

	/// When building an expression, result of the expression is stored into given variable
	string resultVarName( ) {
		return resultVarName_;
	}

public: // Declaration related build commands
	override void build_moduleDefinition( Symbol_Module module_, DeclFunction content ) {
		result_ ~= tabs ~ "// module " ~ module_.identificationString ~ "\n\n";
		content( this );
	}

	override void build_staticVariableDefinition( Symbol_StaticVariable var ) {
		// TODO: implicit value
		result_ ~= tabs ~ "static " ~ cppIdentifier( var.dataType ) ~ " " ~ cppIdentifier( var ) ~ ";\n\n";
	}

	override void build_localVariableDefinition( DataEntity_LocalVariable var ) {
		// TODO: implicit value
		result_ ~= tabs ~ " " ~ cppIdentifier( var.dataType ) ~ " " ~ cppIdentifier( var ) ~ ";\n\n";
	}

	override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
		build_functionPrototype( func );
		result_ ~= "{\n";
		tabOffset_++;

		body_( this );

		tabOffset_--;
		result_ ~= tabs ~ "}\n\n";
	}

public: // Expression related build commands
	override void build_memoryAccess( MemoryPtr pointer ) {
		resultVarName_ = "__staticMemory_%s".format( pointer.val );
	}

	override void build_localVariableAccess( DataEntity_LocalVariable var ) {
		resultVarName_ = cppIdentifier( var );
	}

public: // Statement related build commands
	override void build_if( DataScope scope_, DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
		result_ ~= tabs ~ "{\n";
		tabOffset_++;

		// Build the condition
		{
			condition.buildCode( this, scope_ );
			result_ ~= tabs ~ "if( " ~ resultVarName_ ~ " ) {\n";
		}

		// Build then branch
		{
			tabOffset_++;
			thenBranch( this );
			tabOffset_--;

			result_ ~= tabs ~ "}\n";
		}

		// Build else branch
		if ( elseBranch ) {
			result_ ~= tabs ~ "else {\n";

			tabOffset_++;
			elseBranch( this );
			tabOffset_--;

			result_ ~= tabs ~ "}\n";
		}

		tabOffset_--;
		result_ ~= tabs ~ "}\n";

		resultVarName_ = null;
	}

private:
	void build_functionPrototype( Symbol_RuntimeFunction func ) {
		size_t paremeterCount = 0;
		result_ ~= tabs ~ "void " ~ cppIdentifier( func ) ~ "(";

		// Return value is passed as a pointer
		if ( func.returnType !is coreLibrary.types.Void ) {
			result_ ~= cppIdentifier( func.returnType ) ~ " *result";
			paremeterCount++;
		}

		result_ ~= ")";
	}

private:
	string cppIdentifier( DataEntity_LocalVariable var ) {
		return "_%s__%s".format( var.outerHash.str, var.identifier ? var.identifier.str : "tmp" );
	}

	string cppIdentifier( Symbol sym ) {
		return "_%s__%s".format( sym.outerHash.str, sym.identifier ? sym.identifier.str : "tmp" );
	}

private:
	string tabs( ) {
		string result;
		foreach ( i; 0 .. tabOffset_ )
			result ~= "\t";

		return result;
	}

private:
	Appender!string result_;
	string resultVarName_;
	size_t tabOffset_;

}
