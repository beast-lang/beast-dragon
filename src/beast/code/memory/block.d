module beast.code.memory.block;

import beast.code.toolkit;
import beast.code.memory.ptr;
import beast.code.data.var.local;
import beast.code.data.function_.expandedparameter;
import core.memory : GC;
import core.atomic : atomicOp, atomicLoad;
import beast.code.memory.memorymgr;
import beast.util.uidgen;

/// Block of interpreter memory
final class MemoryBlock {

	public:
		enum Flag {
			noFlag = 0,

			doNotGCAtAll = 1, /// Do not garbage collect this block at all
			doNotMirrorChanges = doNotGCAtAll << 1, /// Do not mirror changes of the @ctime memory block

			ctime = doNotMirrorChanges << 1, /// Memory block is compile time - cannot be written to at runtime

			local = ctime << 1, /// Block is local - it cannot be accessed from other sessions (should not happen at all); tested only in debug; used for local and temporary variables
			dynamicallyAllocated = local << 1, /// The variable has been dynamically allocated (using malloc)
		}

		alias Flags = Flag;

		enum SharedFlag {
			referenced = 1, /// The memory block is referenced from external source (codegen)
			doNotGCAtSessionEnd = referenced << 1, /// Do not garbage collect this block at the end of the session (when only blocks created in the current session are garbage collected)

			// !!! ALTHOUGH FOLLOWING FLAGS ARE IN THE SHAREDFLAG ENUM, THEY ARE TO BE READ/WRITTEN ONLY FROM BLOCK SESSION
			changed = doNotGCAtSessionEnd << 1, /// When the memory block is mirrored in the runtime, this flag helps the tracker (keeps track if block was allocated/freed/written to since last check)
			freed = changed << 1, /// Memory block is freed
			allocated = freed << 1, /// Memory block was allocated since the last check

			sessionFinished = allocated << 1, /// Memory session this block was created in is finished
		}

	public:
		this( MemoryPtr startPtr, size_t size, UIDGenerator.I allocId, Flags flags ) {
			this.startPtr = startPtr;
			this.endPtr = startPtr + size;
			this.size = size;
			this.allocId = allocId;
			this.sharedFlags_ = SharedFlag.changed | SharedFlag.allocated;
			this.flags = flags;

			this.session = context.session;
			this.subSession = context.subSession;
			debug this.jobId = context.jobId;

			if ( isCtime ) {
				data = cast( ubyte* ) GC.malloc( size );
				data[ 0 .. size ] = 0;
			}

			assert( context.session, "You need a session to be able to allocate" );
		}

		~this( ) {
			if( data )
				GC.free( data );
		}

	public:
		/// Duplicates given memory block. The memory block must not be runtime. The resulting block is set static
		MemoryBlock duplicate( Flag flags ) {
			assert( isCtime );
			MemoryBlock result = memoryManager.allocBlock( size, flags );
			memoryManager.write( result.startPtr, data[ 0 .. size ] );
			return result;
		}

	public:
		/// Returns if the block is marked as runtime
		pragma( inline ) bool isRuntime( ) {
			return !flag( Flag.ctime );
		}

		/// Returns if the block is marked as compile time
		pragma( inline ) bool isCtime( ) {
			return flag( Flag.ctime );
		}

		/// Returns if the block is local - if it coresponds to a variable on stack
		pragma( inline ) bool isLocal( ) {
			return flag( Flag.local );
		}

		/// Returns if the block is static - not local nor dynamically allocated
		pragma( inline ) bool isStatic( ) {
			return !flag( Flag.local ) && !flag( Flag.dynamicallyAllocated );
		}

		pragma( inline ) void markReferenced( ) {
			atomicOp!"|="( sharedFlags_, SharedFlag.referenced );
		}

		pragma( inline ) bool isDoNotGCAtSessionEnd( ) {
			return flag( SharedFlag.doNotGCAtSessionEnd );
		}

		pragma( inline ) void markDoNotGCAtSessionEnd( ) {
			debug ( gc ) {
				import std.stdio : writefln;

				writefln( "mark doNotGCSessEnd %s", startPtr );
			}

			atomicOp!"|="( sharedFlags_, SharedFlag.doNotGCAtSessionEnd );
		}

		pragma( inline ) bool isReferenced( ) {
			return flag( SharedFlag.referenced );
		}

		pragma( inline ) bool isSessionFinished( ) {
			return flag( SharedFlag.sessionFinished );
		}

	public:
		pragma( inline ) bool flag( Flag flag ) {
			return ( flags & flag ) == flag;
		}

		pragma( inline ) bool flag( SharedFlag flag ) {
			return ( sharedFlags & flag ) == flag;
		}

		pragma( inline ) auto sharedFlags( ) {
			return atomicLoad( sharedFlags_ );
		}

		pragma( inline ) void setFlags( SharedFlag flag ) {
			atomicOp!"|="( sharedFlags_, flag );
		}

		pragma( inline ) void setFlags( SharedFlag flag, bool set ) {
			if ( set )
				setFlags( flag );
			else
				atomicOp!"&="( sharedFlags_, ~flag );
		}

	public:
		string identificationString( ) {
			if ( relatedDataEntity )
				return relatedDataEntity.identificationString;

			else if ( identifier )
				return identifier;

			else
				return "#var#";
		}

	public:
		int opCmp( const MemoryBlock other ) const {
			return startPtr.opCmp( other.startPtr );
		}

	public:
		/// Number unique to each allocation
		const UIDGenerator.I allocId;
		/// First byte that belongs to the block
		const MemoryPtr startPtr;
		/// First byte that doesn't belong to the block
		const MemoryPtr endPtr;
		/// Size of the block
		const size_t size;
		/// Session the current block was initialized in
		const UIDGenerator.I session;
		/// Subsession the current block was initialized in
		const UIDGenerator.I subSession;
		/// Flags of the block.
		const Flags flags;
		/// Flags that can be modified asynchronously ("atomic or" write only)
		shared ubyte sharedFlags_;
		ubyte* data;

		/// Data entity related to the code block
		DataEntity relatedDataEntity;
		string identifier;

		/// Readable/writable only from block context!
		/// Base pointer offset of a local variable (or mirrored @ctime variable) for the interpreter
		/// OR base pointer offset of a nonstatic @ctime variable for ctimeStack
		size_t bpOffset;

		/// This is for checking if there was reading from a different thread before write
		debug bool wasReadOutsideContext;
		debug UIDGenerator.I jobId;

}
