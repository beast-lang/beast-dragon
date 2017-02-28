module beast.backend.ctime.codebuilder;

import beast.backend.toolkit;

/// "CodeBuilder" that executes data at compile time
/// Because of it's result caching, always use each instance of this codebuilder in one task context only!
final class CodeBuilder_Ctime : CodeBuilder {

public:
	/// Result of the last "built" (read "executed") code
	MemoryPtr result( ) {
		debug {
			assert( result_ );

			auto block = memoryManager.findMemoryBlock( result_ );
			assert( block && !block.isRuntime );
		}

		return result_;
	}

public: // Expression related build commands
	override void build_memoryAccess( MemoryPtr pointer ) {
		MemoryBlock b = memoryManager.findMemoryBlock( pointer );
		benforce( !b.isRuntime, E.valueNotCtime, "Variable is not ctime" );

		result_ = pointer;
	}

	override void build_localVariableAccess( DataEntity_LocalVariable var ) {
		benforce( var.isCtime, E.valueNotCtime, "Variable '%s' is not ctime".format( var.identificationString ) );

		result_ = var.ctimeValue;
	}

private:
	MemoryPtr result_;

}
