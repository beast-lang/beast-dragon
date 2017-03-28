module beast.backend.interpreter.primitiveop.bool_;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_boolNot( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		InstructionOperand arg1v = operandResult_;

		arg2( cb );
		addInstruction( I.boolNot, arg1v, operandResult_ );
	}
}