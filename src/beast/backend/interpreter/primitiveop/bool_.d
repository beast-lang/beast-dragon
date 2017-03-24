module beast.backend.interpreter.primitiveop.bool_;

import beast.backend.interpreter.primitiveop.toolkit;

void primitiveOp_boolOr( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		InstructionOperand result = cb.operandResult_;

		inst.buildCode( cb );
		auto iCond = addInstruction( I.jmpFalse, iopPlaceholder, operandResult_ );

		// If the first operand is true, we don't have to execute the second operand
		addInstruction( I.movConst, result, true.iopLiteral, 1.iopLiteral );
		auto iJmpTrue = addInstruction( I.jmp, iopPlaceholder );

		setInstructionOperand( iCond, 0, jumpTarget );
		pushScope( );
		args[ 1 ].buildCode( cb );
		addInstruction( I.mov, result, operandResult_, 1.iopLiteral );
		popScope( );

		setInstructionOperand( iJmpTrue, 0, jumpTarget );

		operandResult_ = result;
	}
}

void primitiveOp_boolAnd( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		InstructionOperand result = cb.operandResult_;

		inst.buildCode( cb );
		auto iCond = addInstruction( I.jmpTrue, iopPlaceholder, operandResult_ );

		// If the first operand is false, we don't have to execute the second operand
		addInstruction( I.movConst, result, false.iopLiteral, 1.iopLiteral );
		auto iJmpTrue = addInstruction( I.jmp, iopPlaceholder );

		setInstructionOperand( iCond, 0, jumpTarget );
		pushScope( );
		args[ 1 ].buildCode( cb );
		addInstruction( I.mov, result, operandResult_, 1.iopLiteral );
		popScope( );

		setInstructionOperand( iJmpTrue, 0, jumpTarget );

		operandResult_ = result;
	}
}