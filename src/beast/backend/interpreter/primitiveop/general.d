module beast.backend.interpreter.primitiveop.general;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_memZero( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		addInstruction( I.zero, operandResult_, argT.instanceSize.iopLiteral );
	}
}

void primitiveOp_memCpy( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		InstructionOperand arg1v = operandResult_;

		arg2( cb );
		addInstruction( I.mov, arg1v, operandResult_, argT.instanceSize.iopLiteral );
	}
}

void primitiveOp_noopDtor( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	// Do nothing
}

void primitiveOp_print( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	cb.addInstruction( I.printError );
}

void primitiveOp_assert_( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		cb.addInstruction( I.assert_, operandResult_ );
	}
}
