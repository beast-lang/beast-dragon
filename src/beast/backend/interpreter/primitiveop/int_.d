module beast.backend.interpreter.primitiveop.int_;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_intAdd( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.addInstruction( I.intAdd32, arg1, arg2, arg3 );
}

void primitiveOp_intSub( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.addInstruction( I.intSub32, arg1, arg2, arg3 );
}

void primitiveOp_intMult( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.addInstruction( I.intMult32, arg1, arg2, arg3 );
}

void primitiveOp_intDiv( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.addInstruction( I.intDiv32, arg1, arg2, arg3 );
}