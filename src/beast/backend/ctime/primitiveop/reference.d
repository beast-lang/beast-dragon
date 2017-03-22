module beast.backend.ctime.primitiveop.reference;

import beast.backend.ctime.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_refCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		size_t data = 0;

		inst.buildCode( cb );
		result_.write( &data, hardwareEnvironment.effectivePointerSize );
	}
}

void primitiveOp_refCopyCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const MemoryPtr arg1 = result_;

		inst.buildCode( cb );
		result_.write( arg1, hardwareEnvironment.pointerSize );
	}
}

void primitiveOp_refRefCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const MemoryPtr arg1 = result_;

		inst.buildCode( cb );
		result_.write( &arg1.val, hardwareEnvironment.effectivePointerSize );
	}
}