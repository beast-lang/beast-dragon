module beast.backend.ctime.primitiveop.int_;

import beast.backend.ctime.primitiveop.toolkit;

private pragma( inline ) void intOp( string op )( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	switch ( t.instanceSize ) {

	case 1:
		arg1.writePrimitive( mixin( "arg2.readPrimitive!byte %s arg3.readPrimitive!byte".format( op ) ) );
		break;

	case 2:
		arg1.writePrimitive( mixin( "arg2.readPrimitive!short %s arg3.readPrimitive!short".format( op ) ) );
		break;

	case 4:
		arg1.writePrimitive( mixin( "arg2.readPrimitive!int %s arg3.readPrimitive!int".format( op ) ) );
		break;

	case 8:
		arg1.writePrimitive( mixin( "arg2.readPrimitive!long %s arg3.readPrimitive!long".format( op ) ) );
		break;

	default:
		assert( 0, "No operations for integrals with instance size %s".format( t.instanceSize ) );

	}
}

// NUMERIC OPERATIONS
void primitiveOp_intAdd( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	intOp!"+"( cb, t, arg1, arg2, arg3 );
}

void primitiveOp_intSub( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	intOp!"-"( cb, t, arg1, arg2, arg3 );
}

void primitiveOp_intMult( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	intOp!"*"( cb, t, arg1, arg2, arg3 );
}

void primitiveOp_intDiv( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	intOp!"/"( cb, t, arg1, arg2, arg3 );
}

// COMPARISON
void primitiveOp_intGt( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	intOp!">"( cb, t, arg1, arg2, arg3 );
}

void primitiveOp_intGte( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	intOp!">="( cb, t, arg1, arg2, arg3 );
}

void primitiveOp_intLt( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	intOp!"<"( cb, t, arg1, arg2, arg3 );
}

void primitiveOp_intLte( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	intOp!"<="( cb, t, arg1, arg2, arg3 );
}
