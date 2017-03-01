module beast.code.memory.mgr;

import beast.code.hwenv.hwenv;
import beast.code.memory.block;
import beast.code.toolkit;
import beast.core.task.context;
import beast.util.uidgen;
import core.sync.rwmutex;
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
	MemoryBlock allocBlock( size_t bytes ) {
		MemoryPtr endPtr = MemoryPtr( 1 /* +1 to prevent allocating on a null pointer */  );

		synchronized ( mut.writer ) {
			debug assert( context.session in activeSessions, "Invalid session" );

			// First, we try inserting the new block between currently existing memory blocks
			foreach ( i, block; mmap ) {
				if ( endPtr + bytes <= block.startPtr ) {
					MemoryBlock result = new MemoryBlock( endPtr, bytes );
					mmap.insertInPlace( i, result );
					return result;
				}

				endPtr = block.endPtr;
			}

			// If it fails, we add a new memory after all existing blocks
			benforce( endPtr <= MemoryPtr( hardwareEnvironment.memorySize ), E.outOfMemory, "Failed to allocate %s bytes".format( bytes ) );

			MemoryBlock result = new MemoryBlock( endPtr, bytes );
			mmap ~= result;
			return result;
		}
	}

	MemoryPtr alloc( size_t bytes ) {
		return allocBlock( bytes ).startPtr;
	}

	MemoryPtr alloc( size_t bytes, ubyte flags ) {
		MemoryBlock result = allocBlock( bytes );
		result.flags |= flags;
		return result.startPtr;
	}

	void free( MemoryPtr ptr ) {
		checkNullptr( ptr );

		synchronized ( mut.writer ) {
			debug assert( context.session in activeSessions, "Invalid session" );

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

		debug benforce( block.session == context.session, E.protectedMemory, "Cannot write to memory block owned by a different session (block %s; current %s)".format( block.session, context.session ) );
		benforce( block.session == context.session, E.protectedMemory, "Cannot write to memory block owned by a different session" );
		benforce( block.endPtr <= ptr + bytes, E.invalidMemoryOperation, "Memory write outside of allocated block bounds" );
		benforce( !( block.flags & MemoryBlock.Flags.runtime ), E.invalidMemoryOperation, "Cannnot write to runtime memory" );

		debug assert( block.session in activeSessions );
		assert( context.session == block.session );
		debug assert( context.jobId == activeSessions[ block.session ] );

		// We're writing to a memory that is accessed only from one thread (context), so no mutexes should be needed
		memcpy( block.data + ( ptr - block.startPtr ).val, data, bytes );
	}

	/// "Reads" given amount of bytes from memory and returns pointer to them (it doesn't actually read, just does some checks)
	void* read( MemoryPtr ptr, size_t bytes ) {
		MemoryBlock block = findMemoryBlock( ptr );

		// Either the session the block was created in is no longer active (-> the block cannot be changed anymore), or the session belongs to the same task context as current session (meaning it is the same session or a derived one)
		// Other cases should not happen
		debug assert( block.session !in activeSessions || activeSessions[ block.session ] == context.jobId );
		assert( !( block.flags & MemoryBlock.Flags.local ) || block.session == context.session, "Local memory block is accessed from a different session" );

		benforce( block.endPtr <= ptr + bytes, E.invalidMemoryOperation, "Memory read outside of allocated block bounds" );
		benforce( !( block.flags & MemoryBlock.Flags.runtime ), E.invalidMemoryOperation, "Cannnot read from runtime memory" );
		return block.data + ( ptr - block.startPtr ).val;
	}

public:
	/// Finds memory block containing ptr or throws segmentation fault
	MemoryBlock findMemoryBlock( MemoryPtr ptr ) {
		checkNullptr( ptr );

		synchronized ( mut.reader ) {
			foreach ( block; mmap ) {
				if ( ptr >= block.startPtr && ptr < block.endPtr )
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
			activeSessions[ session ] = context.jobId;
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
	/// Map of session id -> jobId
	debug static __gshared size_t[ size_t ] activeSessions;
	ReadWriteMutex mut;

}

