module beast.code.data.var.local;

import beast.code.data.toolkit;

abstract class DataEntity_LocalVariable : DataEntity {

public:
	this( Symbol_Type dataType, bool isCtime ) {
		debug assert( context.jobId == scope_.jobId );

		dataType_ = dataType;
		isCtime_ = isCtime;

		basePointerOffset_ = scope_.currentBasePointerOffset;
		scope_.currentBasePointerOffset += dataType.instanceSize;
	}

public:
	final override Symbol_Type dataType() {
		return dataType_;
	}

	final size_t basePointerOffset( ) {
		return basePointerOffset_;
	}

protected:
	size_t basePointerOffset_;
	Symbol_Type dataType_;
	bool isCtime_;

}
