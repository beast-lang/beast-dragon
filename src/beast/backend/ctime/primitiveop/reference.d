module beast.backend.ctime.primitiveop.reference;

import beast.backend.ctime.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_storeAddr( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const MemoryPtr arg1 = result_;

		inst.buildCode( cb );
		result_.write( &arg1.val, hardwareEnvironment.effectivePointerSize );
	}
}

void primitiveOp_loadAddr( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		result_ = result_.readMemoryPtr;
	}
}