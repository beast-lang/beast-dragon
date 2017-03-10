module beast.backend.ctime.codebuilder;

import beast.backend.toolkit;

/// "CodeBuilder" that executes data at compile time
/// Because of its result caching, always use each instance of this codebuilder in one task context only!
final class CodeBuilder_Ctime : CodeBuilder {

	public:
		this( ) {
			debug jobId_ = context.jobId;
		}

	public:
		/// Result of the last "built" (read "executed") code
		MemoryPtr result( ) {
			debug {
				assert( result_ );
				assert( context.jobId == jobId_ );

				auto block = memoryManager.findMemoryBlock( result_ );
				assert( block && !block.isRuntime );
			}

			return result_;
		}

	public: // Expression related build commands
		override void build_memoryAccess( MemoryPtr pointer ) {
			debug assert( context.jobId == jobId_ );
			
			MemoryBlock b = memoryManager.findMemoryBlock( pointer );
			benforce( !b.isRuntime, E.valueNotCtime, b.isLocal ? "Variable '%s' is not ctime".format( b.localVariable.identificationString ) : "Variable is not ctime" );

			result_ = pointer;
		}

	public:
		final string identificationString( ) {
			return "codebuilder.@ctime";
		}

	private:
		debug size_t jobId_;
		MemoryPtr result_;

}
