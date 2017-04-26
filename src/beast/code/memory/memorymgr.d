module beast.code.memory.memorymgr;

import beast.code.toolkit;
import beast.code.memory.block;
import beast.code.memory.ptr;
import core.sync.rwmutex : ReadWriteMutex;
import beast.code.hwenv.hwenv;
import beast.util.uidgen;
import std.container.rbtree : RedBlackTree;
import std.algorithm.searching : until;
import beast.core.context;
import beast.core.error.error : wereErrors;

debug ( memory ) {
	import std.stdio : writefln;
}

version = sessionEndGCCleanup;
version = finishGCCleanup;

// TODO: sub sessions - you cannot write to data from a different subsession, but data are not garbage collected after subsession end
// This would be used when matching overloads (not we have to markDoNotGCAtSessionEnd)

/// MemoryManager is in charge of all @ctime-allocated memory
__gshared MemoryManager memoryManager;

/// One of the root classes of @ctime
/// Is in charge of all @ctime-allocated memory
final class MemoryManager {

	public:
		this( ) {
			pointerList_ = new RedBlackTree!MemoryPtr;
			pointerListMutex_ = new ReadWriteMutex;
			blockListMutex_ = new ReadWriteMutex;
		}

	public:
		MemoryBlock allocBlock( size_t bytes, MemoryBlock.Flags flags ) {
			import std.array : insertInPlace;

			debug assert( !finished_ );
			assert( bytes, "Trying to allocate 0 bytes" );

			auto ptrSize = hardwareEnvironment.pointerSize;

			// We round the bytes to pointerSize so all the data is aligned
			bytes += ( ptrSize - bytes % ptrSize ) % ptrSize;
			assert( bytes % ptrSize == 0 );

			MemoryPtr endPtr = MemoryPtr( ptrSize /* != 0 to prevent allocating on a null pointer, pointerSize so it is aligned */  );
			MemoryBlock result;

			synchronized ( blockListMutex_.writer ) {
				debug synchronized ( this ) {
					debug assert( context.session in activeSessions_, "Invalid subsession" );
					debug assert( context.jobId == activeSessions_[ context.session ], "Session does not match with the jobId" );
				}

				// First, we try inserting the new block between currently existing memory blocks
				foreach ( i, block; mmap_ ) {
					if ( endPtr + bytes <= block.startPtr ) {
						result = new MemoryBlock( endPtr, bytes, allocIDGenerator_( ), flags );

						mmap_.insertInPlace( i, result );
						//mmap_ = mmap_[ 0 .. i ] ~ result ~ mmap_[ i .. $ ];
						assert( mmap_[ i ] is result );
						assert( mmap_[ i + 1 ] is block );

						break;
					}

					endPtr = block.endPtr;
				}

				if ( !result ) {
					// If it fails, we add a new memory after all existing blocks
					benforce( endPtr <= MemoryPtr( hardwareEnvironment.memorySize ), E.outOfMemory, "Failed to allocate %s bytes".format( bytes ) );

					assert( mmap_.length == 0 || mmap_[ $ - 1 ].endPtr == endPtr );

					result = new MemoryBlock( endPtr, bytes, allocIDGenerator_( ), flags );
					mmap_ ~= result;
				}

				debug {
					MemoryBlock prevBlock = mmap_[ 0 ];
					foreach ( i, block; mmap_[ 1 .. $ ] ) {
						assert( block.startPtr >= prevBlock.endPtr );
						prevBlock = block;
					}
				}
			}

			assert( result.startPtr.val !in context.sessionData.memoryBlocks );
			context.sessionData.memoryBlocks[ result.startPtr.val ] = result;

			// result.setFlags( MemoryBlock.SharedFlag.changed | MemoryBlock.SharedFlag.allocated ); no need - done in memoryblock constructor
			if ( auto chbl = context.sessionData.changedMemoryBlocks ) {
				*chbl ~= result;
				*context.sessionData.newMemoryBlocks ~= result;
			}

			debug ( memory )
				writefln( "ALLOC %s (%s bytes)\n", result.startPtr, bytes );

			return result;
		}

		MemoryPtr alloc( size_t bytes, MemoryBlock.Flags flags ) {
			return allocBlock( bytes, flags ).startPtr;
		}

		MemoryPtr alloc( size_t bytes, MemoryBlock.Flags flags, string identifier = null ) {
			MemoryBlock result = allocBlock( bytes, flags );
			result.identifier = identifier;
			return result.startPtr;
		}

		void free( MemoryPtr ptr ) {
			debug assert( !finished_ );

			checkNullptr( ptr );

			synchronized ( blockListMutex_.writer ) {
				debug synchronized ( this ) {
					debug assert( context.session in activeSessions_, "Invalid subsession" );
					debug assert( context.jobId == activeSessions_[ context.session ], "Session does not match with the jobId" );
				}

				foreach ( i, block; mmap_ ) {
					if ( block.startPtr == ptr ) {
						benforce( block.session == context.session, E.protectedMemory, "Cannot free memory block owned by a different session (%#x)".format( ptr.val ) );
						benforce( block.subSession >= context.subSession, E.protectedMemory, "Cannot free memory block owned by a different subsession (%#x)".format( ptr.val ) );

						mmap_ = mmap_[ 0 .. i ] ~ mmap_[ i + 1 .. $ ];

						assert( block.startPtr.val in context.sessionData.memoryBlocks );
						assert( !block.flag( MemoryBlock.SharedFlag.freed ) );
						context.sessionData.memoryBlocks.remove( block.startPtr.val );

						// We also have to unmark pointers in the block
						context.sessionData.pointers.removeKey( pointersInSessionBlock( block ) );

						if ( auto chbl = context.sessionData.changedMemoryBlocks ) {
							// If the block was both allocated and dealllocated between two change checks, we don't need to have it in the change list at all
							if ( !block.flag( MemoryBlock.SharedFlag.changed ) )
								*chbl ~= block;
						}
						block.setFlags( MemoryBlock.SharedFlag.changed | MemoryBlock.SharedFlag.freed );

						debug ( memory )
							writefln( "FREE %s\n", ptr );

						return;
					}
					else
						benforce( block.startPtr < ptr || block.endPtr >= ptr, E.invalidMemoryOperation, "You have to call free on memory block start pointer, not any pointer in the memory block (%#x)".format( ptr.val ) );
				}
			}

			berror( E.invalidMemoryOperation, "Cannot free - memory with this pointer is not allocated (%#x)".format( ptr.val ) );
		}

		pragma( inline ) void free( MemoryBlock block ) {
			free( block.startPtr );
		}

		// Frees the block in the GC cleanup when finishing memoryMgr
		private void sudoFree( MemoryBlock targetBlock ) {
			debug assert( finished_ );

			foreach ( i, block; mmap_ ) {
				if ( block !is targetBlock )
					continue;

				mmap_ = mmap_[ 0 .. i ] ~ mmap_[ i + 1 .. $ ];
				return;
			}

			assert( 0 );
		}

	public:
		/// Tries to write data at a given pointer. Might fail.
		void write( MemoryPtr ptr, const( ubyte )[ ] data ) {
			import core.stdc.string : memcpy;

			debug assert( !finished_ );

			MemoryBlock block = findMemoryBlock( ptr );

			benforce( block.isCtime, E.runtimeMemoryManipulation, "Cannnot write to runtime memory (%s)".format( block.identificationString ) );
			debug benforce( block.session == context.session, E.protectedMemory, "Cannot write to a memory block owned by a different session (block %s; current %s)".format( block.session, context.session ) );
			benforce( block.session == context.session, E.protectedMemory, "Cannot write to a memory block owned by a different session" );
			benforce( block.subSession >= context.subSession, E.protectedMemory, "Cannot write to a memory block owned by a different subsession" );
			benforce( ptr + data.length <= block.endPtr, E.invalidMemoryOperation, "Memory write outside of allocated block bounds" );

			debug synchronized ( this ) {
				debug assert( block.session in activeSessions_ );
				assert( context.session == block.session );
				debug assert( context.jobId == activeSessions_[ block.session ] );
			}

			debug assert( !block.wasReadOutsideContext, "Block was read outside context before write (race condition might occur)" );

			// We're writing to a memory that is accessed only from one thread (context), so no mutexes should be needed
			memcpy( block.data + ( ptr - block.startPtr ).val, data.ptr, data.length );

			if ( context.sessionData.changedMemoryBlocks && !block.flag( MemoryBlock.SharedFlag.changed ) ) {
				*context.sessionData.changedMemoryBlocks ~= block;
				block.setFlags( MemoryBlock.SharedFlag.changed );
			}
		}

		/// "Reads" given amount of bytes from memory and returns pointer to them (it doesn't actually read, just does some checks)
		const( ubyte )[ ] read( const MemoryPtr ptr, size_t bytes ) {
			MemoryBlock block = findMemoryBlock( ptr );

			// Either the session the block was created in is no longer active (-> the block cannot be changed anymore), or the session belongs to the same task context as current session (meaning it is the same session or a derived one)
			// Other cases should not happen
			debug synchronized ( this ) {
				assert( block.session !in activeSessions_ || activeSessions_[ block.session ] == context.jobId, "Block read from session %s can still be modified in its constructor session %s".format( context.session, block.session ) );
				// We can access a "local" block, as some literals etc. evaluate data into local variables and then use these
				assert( !block.isLocal || block.jobId == context.jobId || block.flag( MemoryBlock.SharedFlag.sessionFinished ), "Local memory block is accessed from a different thread" );
			}

			benforce( ptr + bytes <= block.endPtr, E.invalidMemoryOperation, "Memory read outside of allocated block bounds" );
			benforce( block.isCtime, E.runtimeMemoryManipulation, "Cannnot read from runtime memory (%s)".format( block.identificationString ) );

			debug if ( context.jobId != block.jobId )
				block.wasReadOutsideContext = true;

			return ( block.data + ( ptr - block.startPtr ).val )[ 0 .. bytes ];
		}

	public:
		/// Finds memory block containing ptr or throws segmentation fault
		MemoryBlock findMemoryBlock( const MemoryPtr ptr ) {
			checkNullptr( ptr );

			synchronized ( blockListMutex_.reader ) {
				foreach ( block; mmap_ ) {
					if ( ptr >= block.startPtr && ptr < block.endPtr )
						return block;
				}
			}

			berror( E.invalidPointer, "There's no memory allocated on a given address (%#x)".format( ptr.val ) );
			assert( 0 );
		}

	public:
		void markAsPointer( const MemoryPtr ptr ) {
			debug assert( !finished_ );

			// context.sessionData.pointers is per-context and context can be acessed from one thread only, so we don't need mutexes
			benforce( ptr.val % hardwareEnvironment.pointerSize == 0, E.unalignedMemory, "Pointers must be memory-aligned" );
			benforce( ptr !in context.sessionData.pointers, E.corruptMemory, "Corrupt memory: dual initialization of a pointer" );
			context.sessionData.pointers.insert( ptr );

			auto block = ptr.block;
			if ( context.sessionData.changedMemoryBlocks && !block.flag( MemoryBlock.SharedFlag.changed ) ) {
				block.setFlags( MemoryBlock.SharedFlag.changed );
				*context.sessionData.changedMemoryBlocks ~= block;
			}
		}

		void unmarkAsPointer( const MemoryPtr ptr ) {
			debug assert( !finished_ );

			benforce( ptr in context.sessionData.pointers, E.corruptMemory, "Corrupt memory: destroying unexisting pointer" );
			context.sessionData.pointers.removeKey( ptr );

			auto block = ptr.block;
			if ( context.sessionData.changedMemoryBlocks && !block.flag( MemoryBlock.SharedFlag.changed ) ) {
				block.setFlags( MemoryBlock.SharedFlag.changed );
				*context.sessionData.changedMemoryBlocks ~= block;
			}
		}

		/// Returns if given memory has been marked as pointer previously
		bool isPointer( const MemoryPtr ptr ) {
			debug assert( finished_ );
			return ptr in pointerList_;
		}

		/// Returns next nearest memory pointer (where nextPtr > ptr) or NULL if there is no such pointer
		MemoryPtr nextPointer( const MemoryPtr ptr ) {
			debug assert( finished_ );

			auto range = pointerList_.upperBound( ptr );
			return range.empty ? MemoryPtr( 0 ) : range.front;
		}

		auto pointersInBlock( MemoryBlock block ) {
			debug assert( finished_ );
			return pointerList_.upperBound( block.startPtr - 1 ).until!( x => x >= block.endPtr );
		}

	public:
		/// Returns range of MemoryPtr s - pointer in given block
		/// Works only for blocks allocated by current session
		auto pointersInSessionBlock( MemoryBlock block ) {
			assert( block.session == context.session );
			return context.sessionData.pointers.upperBound( block.startPtr - 1 ).until!( x => x >= block.endPtr );
		}

	public:
		void startSubSession( ) {
			context.subSessionStack ~= context.sessionData.subSessionIDGen++;
		}

		void endSubSession( ) {
			context.subSessionStack.length--;
		}

		void startSession( SessionPolicy policy ) {
			debug assert( !finished_ );

			UIDGenerator.I session = sessionIDGenerator_( );

			context.sessionDataStack ~= context.sessionData;
			context.sessionData = new ContextData.SessionData( session, policy );

			startSubSession( );

			debug synchronized ( this )
				activeSessions_[ context.session ] = context.jobId;
		}

		void endSession( ) {
			debug assert( !finished_ );

			debug ( gc ) import std.stdio : writefln;

			assert( wereErrors || context.sessionData.policy != SessionPolicy.watchCtChanges || context.sessionData.changedMemoryBlocks.length == 0, "There are unmirrored changes left!" );

			endSubSession( );

			// "GC" cleanup blocks at session end
			version ( sessionEndGCCleanup ) {
				MemoryBlock[ ] list;

				foreach ( MemoryBlock block; context.sessionData.memoryBlocks ) {
					if ( block.isDoNotGCAtSessionEnd ) {
						list ~= block;

						debug ( gc )
							writefln( "endsession %s root %s", context.session, block.startPtr );
					}
				}

				while ( list.length ) {
					MemoryBlock block = list[ $ - 1 ];
					list.length--;

					auto pointersInBlock = pointersInSessionBlock( block );
					// This doesn't apply anymore, because @ctime variable destructors aren't called anymore (because it's impossible)
					// assert( wereErrors || ( !block.isLocal && block.isCtime ) || pointersInBlock.empty, "There should be no pointers in local or runtime memory block on session end" );

					if ( block.isRuntime ) {
						assert( pointersInBlock.empty );
						continue;
					}

					foreach ( ptr; pointersInBlock ) {
						MemoryPtr ptrptr = ptr.readMemoryPtr;

						debug ( gc )
							writefln( "endsession %s pointer at %s (=%s)", context.session, ptr, ptrptr );

						if ( ptrptr.isNull )
							continue;

						MemoryBlock block2 = ptrptr.block;
						if ( block2.isDoNotGCAtSessionEnd )
							continue;

						block2.markDoNotGCAtSessionEnd;
						list ~= block2;

						debug ( gc )
							writefln( "endsession %s ref %s -> %s", context.session, block.startPtr, block2.startPtr );
					}
				}

				assert( !list.length );

				// We have to copy blocks to be deleted, because sessionMemoryBlocks shrinks as blocks are freed
				foreach ( MemoryBlock block; context.sessionData.memoryBlocks ) {
					// We cleanup local blocks except for function parameters (because those are used on multiple places, although being local)
					if ( !block.isDoNotGCAtSessionEnd ) {
						debug ( gc )
							writefln( "endsession %s cleanup %s", context.session, block.startPtr );

						list ~= block;
					}
					else {
						debug ( gc )
							writefln( "endsession %s keep %s", context.session, block.startPtr );

						block.setFlags( MemoryBlock.SharedFlag.sessionFinished );
					}
				}

				foreach ( block; list )
					free( block );
			}

			debug synchronized ( this ) {
				debug assert( context.session in activeSessions_, "Invalid session" );
				debug assert( context.jobId == activeSessions_[ context.session ], "Session does not match with the jobId" );

				activeSessions_.remove( context.session );
			}

			synchronized ( pointerListMutex_.writer )
				pointerList_.insert( context.sessionData.pointers[ ] );

			if ( context.sessionDataStack.length ) {
				context.sessionData = context.sessionDataStack[ $ - 1 ];
				context.sessionDataStack.length--;
			}
			else
				context.sessionData = null;
		}

		/// Utility function for use with with( memoryManager.session ) { xxx } - calls startSession on beginning and endSession on end
		auto session( SessionPolicy policy ) {
			static struct Result {
				~this( ) {
					memoryManager.endSession( );
				}

				debug UIDGenerator.I prevSession, newSession;
			}

			debug auto prevSession = context.session;
			startSession( policy );

			debug {
				return Result( prevSession, context.session );
			}
			else
				return Result( );
		}

	public:
		void checkNullptr( MemoryPtr ptr ) {
			benforce( ptr.val != 0, E.nullPointer, "Null pointer" );
		}

	public:
		/// Disables all further memory manipulations
		void finish( ) {
			debug finished_ = true;
			debug assert( activeSessions_.length == 0 );

			// GC all unreferenced blocks
			version ( finishGCCleanup ) {
				MemoryBlock[ ] list;

				foreach ( block; mmap_ ) {
					// We can have a "local" block, as some literals etc. evaluate data into local variables and then use these
					//assert( !block.isLocal, "Local blocks should have been freed already (%s)".format( block.identificationString ) );

					if ( block.isReferenced )
						list ~= block;
				}

				while ( list.length ) {
					MemoryBlock block = list[ $ - 1 ];
					list.length--;

					foreach ( ptr; pointersInBlock( block ) ) {
						MemoryPtr ptrptr = ptr.readMemoryPtr;

						if ( ptrptr.isNull )
							continue;

						MemoryBlock block2 = ptrptr.block;

						if ( block2.isReferenced )
							continue;

						block2.markReferenced;
						list ~= block2;
					}
				}

				// Now we use the list as free list
				foreach ( block; mmap_ ) {
					if ( !block.isReferenced )
						list ~= block;
				}

				foreach ( block; list )
					sudoFree( block );
			}
		}

	public:
		/// Returns range for iterating memory blocks
		auto memoryBlocks( ) {
			debug assert( finished_, "Cannot iterate blocks when not finished" );

			struct Result {

				public:
					MemoryBlock front( ) {
						return mgr_.mmap_[ i_ ];
					}

					bool empty( ) {
						return i_ >= mgr_.mmap_.length;
					}

					void popFront( ) {
						i_++;
					}

				private:
					MemoryManager mgr_;
					size_t i_;

			}

			return Result( this );
		}

	private:
		debug bool finished_;
		/// Sorted array of memory blocks
		MemoryBlock[ ] mmap_; // TODO: Better implementation
		/// Map of session id -> jobId
		debug static __gshared UIDGenerator.I[ UIDGenerator.I ] activeSessions_;

		UIDGenerator allocIDGenerator_, sessionIDGenerator_;

		ReadWriteMutex blockListMutex_, pointerListMutex_;

		/// List of addresses that contain pointers
		/// Data are first stored in context.sessionData.pointers, to this list, they're added after session end
		RedBlackTree!MemoryPtr pointerList_;

}

enum SessionPolicy {
	watchCtChanges,
	inheritCtChangesWatcher,
	doNotWatchCtChanges
}

/// Executes given code in a memory manager session 
pragma( inline ) auto inSession( T )( lazy T dg, SessionPolicy policy ) {
	with ( memoryManager.session( policy ) )
		return dg( );
}

/// Executes given code in a standalone memory manager session (SessionPolicy.doNotWatchCtChanges)
pragma( inline ) auto inStandaloneSession( T )( lazy T dg ) {
	with ( memoryManager.session( SessionPolicy.doNotWatchCtChanges ) )
		return dg( );
}

/// Executes given code in a standalone memory manager subsession session
pragma( inline ) auto inSubSession( T )( lazy T dg ) {
	memoryManager.startSubSession( );
	scope ( exit )
		memoryManager.endSubSession( );

	return dg( );
}
