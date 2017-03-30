module beast.backend.ctime.primitiveop.reference;

import beast.backend.ctime.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_getAddr( CB cb, T t, Op arg1, Op arg2 ) {
	arg1.write( &arg2.val, hardwareEnvironment.effectivePointerSize );
}

void primitiveOp_dereference( CB cb, T t, Op arg1 ) {
	cb.result_ = arg1.readMemoryPtr;
}

void primitiveOp_markPtr( CB cb, T t, Op arg1 ) {
	memoryManager.markAsPointer( arg1 );
}

void primitiveOp_unmarkPtr( CB cb, T t, Op arg1 ) {
	memoryManager.unmarkAsPointer( arg1 );
}
