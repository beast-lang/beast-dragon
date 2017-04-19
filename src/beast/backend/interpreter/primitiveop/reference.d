module beast.backend.interpreter.primitiveop.reference;

import beast.backend.interpreter.primitiveop.toolkit;
import beast.code.hwenv.hwenv;
import beast.backend.interpreter.instruction;

void primitiveOp_getAddr( CB cb, T t, Op arg1, Op arg2 ) {
	cb.addInstruction( I.stAddr, arg1, arg2 );
}

void primitiveOp_dereference( CB cb, T t, Op arg1 ) {
	with ( cb ) {
		result_ = arg1;
		switch ( result_.type ) {

		case InstructionOperand.Type.heapRef: // If the operands are not already references, we simply make them into references
			result_.type = InstructionOperand.Type.refHeapRef;
			break;

		case InstructionOperand.Type.stackRef:
			result_.type = InstructionOperand.Type.refStackRef;
			break;

		case InstructionOperand.Type.ctStackRef:
			result_.type = InstructionOperand.Type.refCtStackRef;
			break;

		case InstructionOperand.Type.refHeapRef: // If the operands are references, we have to dereference them first (store the address into local variable)
		case InstructionOperand.Type.refStackRef:
		case InstructionOperand.Type.refCtStackRef:
			addInstruction( I.allocLocal, currentBPOffset_.iopLiteral, hardwareEnvironment.pointerSize.iopLiteral );
			addInstruction( I.mov, currentBPOffset_.iopBpOffset, result_, hardwareEnvironment.pointerSize.iopLiteral );

			result_ = currentBPOffset_.iopRefBpOffset;

			currentBPOffset_++;
			break;

		default:
			assert( 0, "Invalid operand type" );

		}

	}
}

void primitiveOp_markPtr( CB cb, T t, Op arg1 ) {
	cb.addInstruction( I.markPtr, arg1 );
}

void primitiveOp_unmarkPtr( CB cb, T t, Op arg1 ) {
	cb.addInstruction( I.unmarkPtr, arg1 );
}

void primitiveOp_malloc( CB cb, T t, Op arg1, Op arg2 ) {
	cb.addInstruction( I.malloc, arg1, arg2 );
}

void primitiveOp_free( CB cb, T t, Op arg1 ) {
	cb.addInstruction( I.free, arg1 );
}
