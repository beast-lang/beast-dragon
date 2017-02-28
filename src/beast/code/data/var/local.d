module beast.code.data.var.local;

import beast.code.data.toolkit;

abstract class DataEntity_LocalVariable : DataEntity {

public:
	this( Symbol_Type dataType, DataScope scope_ ) {
		dataType_ = dataType;
		scope__ = scope_;
		isCtime_ = isCtime;

		debug assert( context.jobId == scope__.jobId );

		basePointerOffset_ = scope__.currentBasePointerOffset;
		scope__.currentBasePointerOffset += dataType.instanceSize;

		if ( isCtime_ )
			ctimeValue_ = memoryManager.alloc( dataType_.instanceSize );

		// TODO: constructor calls?
	}

public:
	final override Symbol_Type dataType( ) {
		return dataType_;
	}

	final override bool isCtime( ) {
		return isCtime_;
	}

	final MemoryPtr ctimeValue( ) {
		return ctimeValue_;
	}

	final DataScope scope_( ) {
		return scope__;
	}

	final override DataEntity parent( ) {
		return scope_.parentEntity( );
	}

	final size_t basePointerOffset( ) {
		return basePointerOffset_;
	}

public:
	override void buildCode( CodeBuilder cb, DataScope scope_ ) {
		cb.build_localVariableAccess( this );
	}

protected:
	size_t basePointerOffset_;
	Symbol_Type dataType_;
	DataScope scope__;
	MemoryPtr ctimeValue_;
	bool isCtime_;

}
