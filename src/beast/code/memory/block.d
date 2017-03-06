module beast.code.memory.block;

import beast.code.memory.memorymgr;
import beast.code.memory.ptr;
import beast.code.toolkit;
import core.memory;
import core.atomic;
import beast.code.data.var.local;

/// Block of interpreter memory
final class MemoryBlock {

	public:
		enum Flag {
			doNotGCAtAll = 1 << 0, /// Do not garbage collect this block at all
			doNotGCAtSessionEnd = 1 << 1, /// Do not garbage collect this block at the end of the session (when only blocks created in the current session are garbage collected)
			local = 1 << 2, /// Block is local - it cannot be accessed from other sessions (should not happen at all); tested only in debug; used for local and temporary variables
			runtime = 1 << 3, /// Memory block is runtime - cannot be read/written at compile time
		}
		enum SharedFlag {
			referenced = 1 << 0, /// The memory block is referenced from external source (codegen)
		}

	public:
		this( MemoryPtr startPtr, size_t size ) {
			this.startPtr = startPtr;
			this.endPtr = startPtr + size;
			this.size = size;

			assert( context.session, "You need a session to be able to allocate" );
			this.session = context.session;

			data = GC.malloc( size );
		}

		~this( ) {
			GC.free( data );
		}

	public:
		/// Returns if the block is marked as runtime (just a placeholder for a static variable)
		bool isRuntime( ) {
			return ( flags & Flag.runtime ) != 0;
		}

		/// Returns if the block is local - if it coresponds to a variable on stack
		bool isLocal( ) {
			return ( flags & Flag.local ) != 0;
		}

		void markReferenced() {
			atomicOp!"|="( sharedFlags, SharedFlag.referenced );
		}
		bool isReferenced() {
			return sharedFlags & SharedFlag.referenced;
		}

	public:
		/// First byte that belongs to the block
		const MemoryPtr startPtr;
		/// First byte that doesn't belong to the block
		const MemoryPtr endPtr;
		/// Size of the block
		const size_t size;
		/// Session the current block was initialized in
		const size_t session;
		ubyte flags;
		/// Flags that can be modified asynchronously (atomic or write only)
		shared ubyte sharedFlags;
		void* data;
		/// Memory block can have an identifier - results in more readable C code
		string identifier;

	public:
		/// Used when the block is related to a local variables
		DataEntity_LocalVariable localVariable;

}
