module beast.backend.interpreter.primitiveop.general;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_memZero(CB cb, T t, Op arg1) {
	cb.addInstruction(I.zero, arg1, t.instanceSize.iopLiteral);
}

void primitiveOp_memCpy(CB cb, T t, Op arg1, Op arg2) {
	cb.addInstruction(I.mov, arg1, arg2, t.instanceSize.iopLiteral);
}

void primitiveOp_noopDtor(CB cb) {
	// Do nothing
}

void primitiveOp_print(CB cb, T t, Op arg1) {
	cb.addInstruction(I.printError);
}

void primitiveOp_assert_(CB cb, T t, Op arg1) {
	cb.addInstruction(I.assert_, arg1);
}

void primitiveOp_memEq(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(I.bitsCmp, arg2, arg3, t.instanceSize.iopLiteral);
	cb.addInstruction(I.cmpEq, arg1);
}

void primitiveOp_memNeq(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(I.bitsCmp, arg2, arg3, t.instanceSize.iopLiteral);
	cb.addInstruction(I.cmpNeq, arg1);
}
