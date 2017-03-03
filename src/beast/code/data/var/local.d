module beast.code.data.var.local;

import beast.code.data.toolkit;

abstract class DataEntity_LocalVariable : DataEntity {
	mixin TaskGuard!"outerHashObtaining";

	public:
		this( Symbol_Type dataType, DataScope scope_ ) {
			dataType_ = dataType;
			scope__ = scope_;
			isCtime_ = isCtime;

			assert( scope_ );
			assert( parent );
			assert( dataType );

			debug assert( context.jobId == scope__.jobId );

			auto block = memoryManager.allocBlock( dataType_.instanceSize );
			block.flags |= MemoryBlock.Flags.local;
			block.localVariable = this;

			if ( !isCtime_ )
				block.flags |= MemoryBlock.Flags.runtime;

			memoryPtr_ = block.startPtr;

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
			return memoryPtr_;
		}

		final DataScope scope_( ) {
			return scope__;
		}

		final override DataEntity parent( ) {
			return scope_.parentEntity( );
		}

		override final Hash outerHash( ) {
			enforceDone_outerHashObtaining( );
			return outerHash_;
		}

	public:
		override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			cb.build_memoryAccess( memoryPtr_ );
		}

	protected:
		Symbol_Type dataType_;
		DataScope scope__;
		MemoryPtr memoryPtr_;
		Hash outerHash_;
		bool isCtime_;

	private:
		void execute_outerHashObtaining( ) {
			outerHash_ = parent.outerHash + ( identifier ? identifier.hash : Hash( cast( size_t ) cast( void* ) this ) );
		}

}
