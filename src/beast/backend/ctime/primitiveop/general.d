module beast.backend.ctime.primitiveop.general;

import beast.backend.ctime.primitiveop.toolkit;
import std.range : repeat;

void primitiveOp_memZero( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		result_.write( repeat( cast( ubyte ) 0, argT.instanceSize ).array );
	}
}

void primitiveOp_memCpy( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		const MemoryPtr arg1v = result_;

		arg2( cb );
		arg1v.write( result_, argT.instanceSize );
	}
}

void primitiveOp_noopDtor( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	// Do. absolutely. nothing
}

void primitiveOp_print( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	berror( E.functionNotCtime, "Cannot print to stdout at compile time" );
}

void primitiveOp_assert_( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	arg1( cb );
	benforce( cb.result_.readPrimitive!bool, E.ctAssertFail, "An assert has failed during compile-time execution" );
}
