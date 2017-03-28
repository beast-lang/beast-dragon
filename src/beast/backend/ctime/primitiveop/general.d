module beast.backend.ctime.primitiveop.general;

import beast.backend.ctime.primitiveop.toolkit;
import std.range : repeat;

void primitiveOp_memZero( CB cb, T t, Op arg1 ) {
	arg1.write( repeat( cast( ubyte ) 0, t.instanceSize ).array );
}

void primitiveOp_memCpy( CB cb, T t, Op arg1, Op arg2 ) {
	arg1.write( arg2, t.instanceSize );
}

void primitiveOp_noopDtor( CB cb ) {
	// Do. absolutely. nothing
}

void primitiveOp_print( CB cb ) {
	berror( E.functionNotCtime, "Cannot print to stdout at compile time" );
}

void primitiveOp_assert_( CB cb, T t, Op arg1 ) {
	benforce( arg1.readPrimitive!bool, E.ctAssertFail, "An assert has failed during compile-time execution" );
}
