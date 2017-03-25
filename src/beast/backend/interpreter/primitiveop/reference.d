module beast.backend.interpreter.primitiveop.reference;

import beast.backend.interpreter.primitiveop.toolkit;
import beast.code.hwenv.hwenv;
import beast.backend.interpreter.instruction;

void primitiveOp_storeAddr( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const auto arg1 = operandResult_;

		inst.buildCode( cb );
		addInstruction( I.stAddr, operandResult_, arg1 );
	}
}

void primitiveOp_loadAddr( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		switch ( operandResult_.type ) {

		case InstructionOperand.Type.heapRef: // If the operands are not already references, we simply make them into references
			operandResult_.type = InstructionOperand.Type.refHeapRef;
			break;

		case InstructionOperand.Type.stackRef:
			operandResult_.type = InstructionOperand.Type.refStackRef;
			break;

		case InstructionOperand.Type.refHeapRef: // If the operands are references, we have to dereference them first (store the address into local variable)
		case InstructionOperand.Type.refStackRef:
			addInstruction( I.allocLocal, currentBPOffset_.iopLiteral, hardwareEnvironment.pointerSize.iopLiteral );
			addInstruction( I.mov, currentBPOffset_.iopBpOffset, operandResult_, hardwareEnvironment.pointerSize.iopLiteral );

			operandResult_.type = InstructionOperand.Type.refStackRef;
			operandResult_.basePointerOffset = currentBPOffset_;
			
			currentBPOffset_++;
			break;

		default:
			assert( 0, "Invalid operand type" );

		}

	}
}
