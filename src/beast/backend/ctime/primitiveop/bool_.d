module beast.backend.ctime.primitiveop.bool_;

import beast.backend.ctime.primitiveop.toolkit;

void primitiveOp_boolNot(CB cb, T t, Op arg1, Op arg2) {
	arg1.writePrimitive(!arg2.readPrimitive!bool);
}
