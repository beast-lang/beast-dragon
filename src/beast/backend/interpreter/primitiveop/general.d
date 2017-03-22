module beast.backend.interpreter.primitiveop.general;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_zeroInitCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		addInstruction( I.zero, operandResult_, inst.dataType.instanceSize.iopLiteral );
	}
}

void primitiveOp_primitiveCopyCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
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
