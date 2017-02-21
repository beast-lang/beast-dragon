module beast.code.data.localvar.localvar;

import beast.code.data.toolkit;

abstract class DataEntity_LocalVariable : DataEntity {

public:
	this( DataScope scope_ ) {
		super( scope_ );
		debug assert( context.jobId == scope_.jobId );

		basePointerOffset_ = scope_.currentBasePointerOffset;
		scope_.currentBasePointerOffset += dataType.instanceSize;
	}

public:
	final size_t basePointerOffset( ) {
		return basePointerOffset_;
	}

private:
	size_t basePointerOffset_;

}
