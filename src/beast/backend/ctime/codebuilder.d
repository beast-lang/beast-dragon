module beast.backend.ctime.codebuilder;

import beast.backend.toolkit;

/// "CodeBuilder" that executes data at compile time
/// Because of it's result caching, always use each instance of this codebuilder in one task context only!
final class CodeBuilder_Ctime : CodeBuilder {

public:
	/// Result of the last executed expression
	MemoryPtr result( ) {
		debug assert( result_ );
		return result_;
	}

public:
	override void build_staticMemoryAccess( MemoryPtr pointer ) {
		MemoryBlock b = memoryManager.findMemoryBlock( pointer );
		benforce( !b.isRuntime, E.valueNotCtime, "Variable is not ctime" );

		result_ = pointer;
	}

	override void build_localVariableAccess( DataEntity_LocalVariable var ) {
		benforce( var.isCtime, E.valueNotCtime, "Variable '%s' is not ctime".format( var.identificationString ) );
		
		result_ = var.ctimeValue;
	}

public:
	override void build_if( DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
		assert( condition.dataType is coreLibrary.types.Bool );

		result_ = nullMemoryPtr;
		assert( 0 );
	}

private:
	MemoryPtr result_;

}
