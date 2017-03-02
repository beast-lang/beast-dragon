module beast.backend.common.codebuilder;

import beast.backend.toolkit;

/// Root class for building code with any backend
abstract class CodeBuilder {

public:
	/// When called, StmtFunction should build given part of the statement using provided codebuilder
	alias StmtFunction = void delegate( CodeBuilder cb );

	/// When called, DeclFunction should build relevant declarations using provided codebuilder
	alias DeclFunction = void delegate( CodeBuilder cb );

public: // Declaration related build commands
	void build_moduleDefinition( Symbol_Module module_, DeclFunction content ) {
		assert( 0 );
	}

	void build_staticVariableDefinition( Symbol_StaticVariable var ) {
		assert( 0 );
	}

	void build_localVariableDefinition( DataEntity_LocalVariable var ) {
		assert( 0 );
	}

	void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
		assert( 0 );
	}

public: // Expression related build commands
	/// Builds access to a memory (passed by a pointer)
	/// The memory doesn't have to be static! You have to check associated memory block flags (it can be local ctime variable or so)
	void build_memoryAccess( MemoryPtr pointer ) {
		assert( 0 );
	}

	void build_localVariableAccess( DataEntity_LocalVariable var ) {
		assert( 0 );
	}

	void build_functionCall( DataScope scope_, Symbol_RuntimeFunction function_, DataEntity[] arguments ) {
		assert( 0 );
	}

public: // Statement related build commands
	/// Builds the "if" construction
	/// Condition has to be of type bool
	/// elseBranch can be null
	void build_if( DataScope scope_, DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
		assert( 0 );
	}

}
