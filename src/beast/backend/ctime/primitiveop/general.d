module beast.backend.ctime.primitiveop.general;

import beast.backend.ctime.primitiveop.toolkit;
import std.range : repeat;

debug ( ctime ) import std.stdio : writefln;

void primitiveOp_memZero( CB cb, T t, Op arg1 ) {
	arg1.write( repeat( cast( ubyte ) 0, t.instanceSize ).array );

	debug ( ctime )
		writefln( "CTIME zero %s, %s", arg1, t.instanceSize );
}

void primitiveOp_memCpy( CB cb, T t, Op arg1, Op arg2 ) {
	arg1.write( arg2, t.instanceSize );

	debug ( ctime )
		writefln( "CTIME memcpy %s => %s, %s (%s)", arg2, arg1, t.instanceSize, arg1.read( t.instanceSize ) );
}

void primitiveOp_memEq( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	arg1.writePrimitive( arg2.read( t.instanceSize ) == arg3.read( t.instanceSize ) );
}

void primitiveOp_memNeq( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	arg1.writePrimitive( arg2.read( t.instanceSize ) != arg3.read( t.instanceSize ) );
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
