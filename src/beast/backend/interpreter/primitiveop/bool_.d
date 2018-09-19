module beast.backend.interpreter.primitiveop.bool_;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_boolNot(CB cb, T argT, Op arg1, Op arg2) {
	cb.addInstruction(I.boolNot, arg1, arg2);
}
