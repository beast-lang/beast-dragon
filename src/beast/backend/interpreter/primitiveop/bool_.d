module beast.backend.interpreter.primitiveop.bool_;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_boolCtor( CodeBuilder_Interpreter cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		addInstruction( I.movConst, operandResult_, 0.iopLiteral, 1.iopLiteral );
	}
}

void primitiveOp_boolCopyCtor( CodeBuilder_Interpreter cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		InstructionOperand arg1 = operandResult_;

		inst.buildCode( cb );
		addInstruction( I.mov, operandResult_, arg1, 1.iopLiteral );
	}
}