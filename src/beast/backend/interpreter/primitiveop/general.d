module beast.backend.interpreter.primitiveop.general;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_memZero( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		addInstruction( I.zero, operandResult_, inst.dataType.instanceSize.iopLiteral );
	}
}

void primitiveOp_memCpy( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		InstructionOperand arg1 = operandResult_;

		inst.buildCode( cb );
		addInstruction( I.mov, operandResult_, arg1, inst.dataType.instanceSize.iopLiteral );
	}
}

void primitiveOp_noopDtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	// Do nothing
}

void primitiveOp_print( CB cb, DataEntity inst, DataEntity[ ] args ) {
	cb.addInstruction( I.printError );
}

void primitiveOp_assert_( CB cb, DataEntity inst, DataEntity[ ] args ) {
	args[ 0 ].buildCode( cb );
	cb.addInstruction( I.assert_, cb.operandResult_ );
}
