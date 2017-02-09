module beast.code.memory.mgr;

import std.typecons;
import core.memory;
import beast.util.uidgen;
import beast.toolkit;
import beast.code.hwenv.hwenv;
import std.container.rbtree;

/// MemoryManager is in charge of all @ctime-allocated memory
__gshared MemoryManager memoryManager;

/// One of the root classes of @ctime
/// Is in charge of all @ctime-allocated memory
final class MemoryManager {

public:
	MemoryPtr alloc( size_t bytes ) {
		MemoryPtr endPtr = MemoryPtr( bytes );

		synchronized ( this ) {
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
		synchronized ( this ) {
			assert( context.session in activeSessions, "Invalid session" );

			foreach ( i, block; mmap ) {
				if ( block.startPtr == ptr ) {
					benforce( block.session == context.session, E.protectedMemory, "Cannot free - memory block was allocated in different session (%s)".format( ptr ) );
					mmap.remove( i );
					return;

				}
				else
					benforce( block.startPtr < ptr || block.endPtr >= ptr, E.invalidMemoryOperation, "You have to call free on memory block start pointer (%s), not any pointer in the memory block (%s)".format( block.startPtr, ptr ) );
			}
		}

		berror( E.invalidMemoryOperation, "Free failed - memory with this pointer is not allocated (%s)".format( ptr ) );
	}

public:
	static void startSession( ) {
		static __gshared UIDGenerator sessionUIDGen;

		size_t session = sessionUIDGen( );
		context.sessionStack ~= session;
		context.session = session;

		debug synchronized ( memoryManager ) {
			activeSessions.insert( session );
		}
	}

	static void endSession( ) {
		debug synchronized ( memoryManager ) {
			assert( context.session in activeSessions, "Invalid session" );
			activeSessions.removeKey( context.session );
		}

		context.sessionStack.length--;
		context.session = context.sessionStack.length ? context.sessionStack[ $ - 1 ] : 0;
	}

private:
	/// Sorted array of memory blocks
	MemoryBlock[ ] mmap; // TODO: Better implementation
	debug static __gshared RedBlackTree!size_t activeSessions;

}

/// Pointer to Beast interpret memory (target machine memory)
struct MemoryPtr {

public:
	size_t val;

public:
	int opCmp( MemoryPtr other ) const {
		if ( val > other.val )
			return 1;
		else if ( val < other.val )
			return -1;
		else
			return 0;
	}

	MemoryPtr opBinary( string op )( MemoryPtr other ) if ( op == "+" || op == "-" ) {
		return mixin( "MemoryPtr( val " ~ op ~ " other.val )" );
	}

	MemoryPtr opBinary( string op )( size_t other ) if ( op == "+" || op == "-" ) {
		return mixin( "MemoryPtr( val " ~ op ~ " other )" );
	}

	string toString( ) const {
		return "0x%x".format( val );
	}

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
