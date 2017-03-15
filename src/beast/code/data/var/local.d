module beast.code.data.var.local;

import beast.code.data.toolkit;

abstract class DataEntity_LocalVariable : DataEntity {
	mixin TaskGuard!"outerHashObtaining";

	public:
		this( Symbol_Type dataType, DataScope scope_, bool isCtime, MemoryBlock.Flags additionalMemoryBlockFlags = MemoryBlock.Flag.noFlag ) {
			dataType_ = dataType;
			isCtime_ = isCtime;
			scope__ = scope_;

			assert( parent );
			assert( dataType );

			debug assert( context.jobId == scope_.jobId );

			memoryBlock_ = memoryManager.allocBlock( dataType_.instanceSize, MemoryBlock.Flag.local | additionalMemoryBlockFlags );
			memoryBlock_.localVariable = this;

			if ( !isCtime_ )
				memoryBlock_.flags |= MemoryBlock.Flag.runtime;

			// TODO: constructor calls?
		}

	public:
		final override Symbol_Type dataType( ) {
			return dataType_;
		}

		final override bool isCtime( ) {
			return isCtime_;
		}

		final MemoryPtr memoryPtr( ) {
			return memoryBlock_.startPtr;
		}

		final override DataEntity parent( ) {
			return scope__.parentEntity( );
		}

		override final Hash outerHash( ) {
			enforceDone_outerHashObtaining( );
			return outerHashWIP_;
		}

	public:
		override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			cb.build_memoryAccess( memoryPtr );
		}

	public:
		/// Base pointer offset of the local variable in embedded interpreter
		/// Please note that the poitner does not count as offset in bytes, it is an index of the variable in an array (stack is not a linear address space)
		size_t interpreterBpOffset;

	protected:
		Symbol_Type dataType_;
		DataScope scope__;
		MemoryBlock memoryBlock_;
		Hash outerHashWIP_;
		bool isCtime_;

	private:
		void execute_outerHashObtaining( ) {
			// TODO: hashing this pointer is horrible
			outerHashWIP_ = parent.outerHash + ( identifier ? identifier.hash : Hash( cast( size_t ) cast( void* ) this ) );
		}

}
