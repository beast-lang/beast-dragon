module beast.backend.ctime.primitiveop.general;

import beast.backend.ctime.primitiveop.toolkit;
import std.range : repeat;

void primitiveOp_zeroInitCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		result_.write( repeat( cast( ubyte ) 0, inst.dataType.instanceSize ).array );
	}
}

void primitiveOp_primitiveCopyCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const MemoryPtr arg1 = result_;

		inst.buildCode( cb );
		result_.write( arg1, inst.dataType.instanceSize );
	}
}

void primitiveOp_noopDtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	// Do. absolutely. nothing
}

void primitiveOp_print( CB cb, DataEntity inst, DataEntity[ ] args ) {
	berror( E.functionNotCtime, "Cannot print to stdout at compile time" );
}
