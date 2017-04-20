module beast.backend.interpreter.primitiveop.reference;

import beast.backend.interpreter.primitiveop.toolkit;
import beast.code.hwenv.hwenv;
import beast.backend.interpreter.instruction;

void primitiveOp_getAddr( CB cb, T t, Op arg1, Op arg2 ) {
	cb.addInstruction( I.stAddr, arg1, arg2 );
}

void primitiveOp_markPtr( CB cb, T t, Op arg1 ) {
	cb.addInstruction( I.markPtr, arg1 );
}

void primitiveOp_unmarkPtr( CB cb, T t, Op arg1 ) {
	cb.addInstruction( I.unmarkPtr, arg1 );
}

void primitiveOp_malloc( CB cb, T t, Op arg1, Op arg2 ) {
	cb.addInstruction( I.malloc, arg1, arg2 );
}

void primitiveOp_free( CB cb, T t, Op arg1 ) {
	cb.addInstruction( I.free, arg1 );
}
