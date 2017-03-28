module beast.backend.ctime.primitiveop.bool_;

import beast.backend.ctime.primitiveop.toolkit;

void primitiveOp_boolNot( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		const MemoryPtr arg1v = result_;

		arg2( cb );
		arg1v.writePrimitive( !result_.readPrimitive!bool );
	}
}