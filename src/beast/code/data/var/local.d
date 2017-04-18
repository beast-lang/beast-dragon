module beast.code.data.var.local;

import beast.code.data.toolkit;

abstract class DataEntity_LocalVariable : DataEntity {
	mixin TaskGuard!"outerHashObtaining";

	public:
		this( Symbol_Type dataType, bool isCtime, MemoryBlock.Flags additionalMemoryBlockFlags = MemoryBlock.Flag.noFlag ) {
			super( MatchLevel.fullMatch );

			assert( dataType.instanceSize != 0, "DataType %s instanceSize 0".format( dataType.identificationString ) );
			assert( currentScope, "Initializing local variable outside scope" );

			dataType_ = dataType;
			isCtime_ = isCtime;
			scope__ = currentScope;

			assert( parent );
			assert( dataType );

			debug assert( context.jobId == scope__.jobId );

			memoryBlock_ = memoryManager.allocBlock( dataType_.instanceSize, MemoryBlock.Flag.local | additionalMemoryBlockFlags );
			memoryBlock_.relatedDataEntity = this;

			if ( !isCtime_ )
				memoryBlock_.flags |= MemoryBlock.Flag.runtime;
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

		final MemoryBlock memoryBlock( ) {
			return memoryBlock_;
		}

		final override DataEntity parent( ) {
			return scope__.parentEntity( );
		}

		override final Hash outerHash( ) {
			enforceDone_outerHashObtaining( );
			return outerHashWIP_;
		}

		override string identificationString( ) {
			return "%s %s".format( dataType.tryGetIdentificationString, identificationString_noPrefix );
		}

		override void buildCode( CodeBuilder cb ) {
			cb.build_memoryAccess( memoryPtr );
		}

	public:
		/// Return data entity representing copy constructor call for given variable
		final DataEntity getCopyCtor( DataEntity initValue ) {
			// We don't call var.tryResolveIdentifier because of Type variables
			// calling var.tryResolveIdentifier would result in calling #ctor of the represented type
			return dataType.expectResolveIdentifier_direct( ID!"#ctor", this ).resolveCall( ast, true, initValue );
		}
		

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
