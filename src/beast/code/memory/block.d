module beast.code.memory.block;

import beast.code.memory.mgr;
import beast.code.memory.ptr;
import beast.code.toolkit;
import core.memory;

/// Block of interpreter memory
final class MemoryBlock {

public:
	enum Flags {
		doNotGCAtAll = 1 << 0, /// Do not garbage collect this block at all
		doNotGCAtSessionEnd = 1 << 1, /// Do not garbage collect this block at the end of the session (when only blocks created in the current session are garbage collected)
		local = 1 << 2, /// Block is local - it cannot be accessed from other sessions (should not happen at all); tested only in debug
		runtime = 1 << 3, /// Memory block is runtime - cannot be read/written at compile time
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
		return ( flags & Flags.runtime ) != 0;
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
	void* data;

}
