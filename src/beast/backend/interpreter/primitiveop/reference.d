module beast.backend.interpreter.primitiveop.reference;

import beast.backend.interpreter.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_refCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		size_t data = 0;

		inst.buildCode( cb );
		addInstruction( I.movConst, operandResult_, 0.iopLiteral, hardwareEnvironment.effectivePointerSize.iopLiteral );
	}
}

void primitiveOp_refCopyCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const auto arg1 = operandResult_;

		inst.buildCode( cb );
		addInstruction( I.mov, operandResult_, arg1, hardwareEnvironment.effectivePointerSize.iopLiteral );
	}
}

void primitiveOp_refRefCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const auto arg1 = operandResult_;

		inst.buildCode( cb );
		addInstruction( I.stAddr, operandResult_, arg1 );
	}
}