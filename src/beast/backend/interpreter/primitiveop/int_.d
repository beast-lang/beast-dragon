module beast.backend.interpreter.primitiveop.int_;

import beast.backend.interpreter.primitiveop.toolkit;

// NUMERIC OPERATIONS
void primitiveOp_intAdd(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(numericI(t.instanceSize, NumI.add), arg1, arg2, arg3);
}

void primitiveOp_intSub(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(numericI(t.instanceSize, NumI.sub), arg1, arg2, arg3);
}

void primitiveOp_intMult(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(numericI(t.instanceSize, NumI.mult), arg1, arg2, arg3);
}

void primitiveOp_intDiv(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(numericI(t.instanceSize, NumI.div), arg1, arg2, arg3);
}

// COMPARISON
void primitiveOp_intGt(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(numericI(t.instanceSize, NumI.cmp), arg2, arg3);
	cb.addInstruction(I.cmpGt, arg1);
}

void primitiveOp_intGte(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(numericI(t.instanceSize, NumI.cmp), arg2, arg3);
	cb.addInstruction(I.cmpGte, arg1);
}

void primitiveOp_intLt(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(numericI(t.instanceSize, NumI.cmp), arg2, arg3);
	cb.addInstruction(I.cmpLt, arg1);
}

void primitiveOp_intLte(CB cb, T t, Op arg1, Op arg2, Op arg3) {
	cb.addInstruction(numericI(t.instanceSize, NumI.cmp), arg2, arg3);
	cb.addInstruction(I.cmpLte, arg1);
}

void primitiveOp_int32To64(CB cb, T t, Op arg1, Op arg2) {
	cb.addInstruction(I.int32To64, arg1, arg2);
}
