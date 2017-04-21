module beast.backend.cpp.primitiveop.int_;

import beast.backend.cpp.primitiveop.toolkit;

pragma( inline ) string intType( size_t instanceSize ) {
	switch ( instanceSize ) {

	case 0:
		assert( 0 );

	case 1:
		return "int8_t";

	case 2:
		return "int16_t";

	case 4:
		return "int32_t";

	case 8:
		return "int64_t";

	default:
		return null;

	}
}

void primitiveOp_intAdd( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	string tp = intType( t.instanceSize );
	cb.codeResult_.formattedWrite( "%sVAL( %s, %s ) = VAL( %s, %s ) + VAL( %s, %s );\n", cb.tabs, arg1, tp, arg2, tp, arg3, tp );
}

void primitiveOp_intSub( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	string tp = intType( t.instanceSize );
	cb.codeResult_.formattedWrite( "%sVAL( %s, %s ) = VAL( %s, %s ) - VAL( %s, %s );\n", cb.tabs, arg1, tp, arg2, tp, arg3, tp );
}

void primitiveOp_intMult( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	string tp = intType( t.instanceSize );
	cb.codeResult_.formattedWrite( "%sVAL( %s, %s ) = VAL( %s, %s ) * VAL( %s, %s );\n", cb.tabs, arg1, tp, arg2, tp, arg3, tp );
}

void primitiveOp_intDiv( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	string tp = intType( t.instanceSize );
	cb.codeResult_.formattedWrite( "%sVAL( %s, %s ) = VAL( %s, %s ) / VAL( %s, %s );\n", cb.tabs, arg1, tp, arg2, tp, arg3, tp );
}

void primitiveOp_intGt( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	string tp = intType( t.instanceSize );
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, %s ) > VAL( %s, %s );\n", cb.tabs, arg1, arg2, tp, arg3, tp );
}

void primitiveOp_intGte( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	string tp = intType( t.instanceSize );
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, %s ) >= VAL( %s, %s );\n", cb.tabs, arg1, arg2, tp, arg3, tp );
}

void primitiveOp_intLt( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	string tp = intType( t.instanceSize );
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, %s ) < VAL( %s, %s );\n", cb.tabs, arg1, arg2, tp, arg3, tp );
}

void primitiveOp_intLte( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	string tp = intType( t.instanceSize );
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, %s ) <= VAL( %s, %s );\n", cb.tabs, arg1, arg2, tp, arg3, tp );
}

void primitiveOp_int32To64( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, int64_t ) = (int64_t) VAL( %s, int32_t );\n", cb.tabs, arg1, arg2 );
}
