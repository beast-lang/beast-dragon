module beast.backend.ctime.primitiveop.reference;

import beast.backend.ctime.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_getAddr( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		const MemoryPtr arg1v = result_;

		arg2( cb );
		arg1v.write( &result_.val, hardwareEnvironment.effectivePointerSize );
	}
}

void primitiveOp_dereference( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		result_ = result_.readMemoryPtr;
	}
}