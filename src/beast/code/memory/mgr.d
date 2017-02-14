module beast.code.memory.mgr;

import std.typecons;
import core.memory;
import beast.util.uidgen;
import beast.code.toolkit;
import beast.code.hwenv.hwenv;
import core.sync.rwmutex;
import beast.core.task.context;
import core.stdc.string;

/// MemoryManager is in charge of all @ctime-allocated memory
__gshared MemoryManager memoryManager;

/// One of the root classes of @ctime
/// Is in charge of all @ctime-allocated memory
final class MemoryManager {

public:
	this( ) {
		mut = new ReadWriteMutex;
	}

public:
	MemoryPtr alloc( size_t bytes )
	out ( result ) {
		assert( result.val != 0, "Alloc should not return a null pointer" );
	}
	body {
		MemoryPtr endPtr = MemoryPtr( bytes + 1 /* +1 to prevent allocating on a null pointer */  );

		synchronized ( mut.writer ) {
			assert( context.session in activeSessions, "Invalid session" );

			// First, we try inserting the new block between currently existing memory blocks
			foreach ( i, block; mmap ) {
				if ( endPtr <= block.startPtr ) {
					MemoryBlock result = new MemoryBlock( endPtr - bytes, bytes );
					mmap.insertInPlace( i, result );
					return result.startPtr;
				}

				endPtr = block.endPtr;
			}

			// If it fails, we add a new memory after all existing blocks
			benforce( endPtr <= MemoryPtr( hardwareEnvironment.memorySize ), E.outOfMemory, "Failed to allocate %s bytes".format( bytes ) );

			MemoryBlock result = new MemoryBlock( endPtr - bytes, bytes );
			mmap ~= result;
			return result.startPtr;
		}
	}

	void free( MemoryPtr ptr ) {
		checkNullptr( ptr );

		synchronized ( mut.writer ) {
			assert( context.session in activeSessions, "Invalid session" );

			foreach ( i, block; mmap ) {
				if ( block.startPtr == ptr ) {
					benforce( block.session == context.session, E.protectedMemory, "Cannot free memory block owned by a different session" );
					mmap.remove( i );
					return;

				}
				else
					benforce( block.startPtr < ptr || block.endPtr >= ptr, E.invalidMemoryOperation, "You have to call free on memory block start pointer, not any pointer in the memory block" );
			}
		}

		berror( E.invalidMemoryOperation, "Cannot free - memory with this pointer is not allocated" );
	}

public:
	/// Tries to write data at a given pointer. Might fail.
	void write( MemoryPtr ptr, void* data, size_t bytes ) {
		MemoryBlock block = findMemoryBlock( ptr );

		benforce( block.session == context.session, E.protectedMemory, "Cannot write to memory block owned by a different session" );
		benforce( block.endPtr <= ptr + bytes, E.invalidMemoryOperation, "Memory write outside of allocated block bounds" );

		assert( block.session in activeSessions );
		assert( context.session == block.session );
		assert( context.taskContext == activeSessions[ block.session ] );

		// We're writing to a memory that is accessed only from one thread (context), so no mutexes should be needed
		memcpy( block.data + ( ptr - block.startPtr ).val, data, bytes );
	}

	/// "Reads" given amount of bytes from memory and returns pointer to them (it doesn't actually read, just does some checks)
	void* read( MemoryPtr ptr, size_t bytes ) {
		MemoryBlock block = findMemoryBlock( ptr );

		// Either the session the block was created in is no longer active (-> the block cannot be changed anymore), or the session belongs to the same task context as current session (meaning it is the same session or a derived one)
		// Other cases should not happen
		assert( block.session !in activeSessions || activeSessions[ block.session ] == context.taskContext );

		benforce( block.endPtr <= ptr + bytes, E.invalidMemoryOperation, "Memory read outside of allocated block bounds" );
		return block.data + ( ptr - block.startPtr ).val;
	}

public:
	/// Finds memory block containing ptr or throws segmentation fault
	MemoryBlock findMemoryBlock( MemoryPtr ptr ) {
		checkNullptr( ptr );

		synchronized ( mut.reader ) {
			foreach ( block; mmap ) {
				if ( block.startPtr >= ptr && block.endPtr < ptr )
					return block;
			}
		}

		berror( E.invalidPointer, "There's no memory allocated on a given address" );
		assert( 0 );
	}

public:
	static void startSession( ) {
		static __gshared UIDGenerator sessionUIDGen;

		size_t session = sessionUIDGen( );
		context.sessionStack ~= session;
		context.session = session;

		debug synchronized ( memoryManager ) {
			activeSessions[ session ] = context.taskContext;
		}
	}

	static void endSession( ) {
		debug synchronized ( memoryManager ) {
			assert( context.session in activeSessions, "Invalid session" );
			activeSessions.remove( context.session );
		}

		context.sessionStack.length--;
		context.session = context.sessionStack.length ? context.sessionStack[ $ - 1 ] : 0;
	}

	/// Utility function for use with with( memoryManager.session ) { xxx } - calls startSession on beginning and endSession on end
	static auto session( ) {
		static struct Result {
			~this( ) {
				endSession( );
			}
		}

		startSession( );
		return Result( );
	}

public:
	void checkNullptr( MemoryPtr ptr ) {
		benforce( ptr.val != 0, E.nullPointer, "Null pointer" );
	}

private:
	/// Sorted array of memory blocks
	MemoryBlock[ ] mmap; // TODO: Better implementation
	/// Map of session id -> task context
	debug static __gshared TaskContext[ size_t ] activeSessions;
	ReadWriteMutex mut;

}

/// Block of interpreter memory
final class MemoryBlock {

public:
	this( MemoryPtr startPtr, size_t size ) {
		this.startPtr = startPtr;
		this.endPtr = startPtr + size;
		this.size = size;

		assert( context.session, "You need a session to be able to allocate" );
		this.session = context.session;

		data = GC.malloc( size );
	}
	~this() {
		GC.free( data );
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
	void* data;

}
