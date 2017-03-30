module beast.backend.cpp.primitiveop.int_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_intAdd( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, int32_t ) = VAL( %s, int32_t ) + VAL( %s, int32_t );\n", cb.tabs, arg1, arg2, arg3 );
}

void primitiveOp_intSub( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, int32_t ) = VAL( %s, int32_t ) - VAL( %s, int32_t );\n", cb.tabs, arg1, arg2, arg3 );
}

void primitiveOp_intMult( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, int32_t ) = VAL( %s, int32_t ) * VAL( %s, int32_t );\n", cb.tabs, arg1, arg2, arg3 );
}

void primitiveOp_intDiv( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, int32_t ) = VAL( %s, int32_t ) / VAL( %s, int32_t );\n", cb.tabs, arg1, arg2, arg3 );
}

void primitiveOp_intGt( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, int32_t ) > VAL( %s, int32_t );\n", cb.tabs, arg1, arg2, arg3 );
}

void primitiveOp_intGte( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, int32_t ) >= VAL( %s, int32_t );\n", cb.tabs, arg1, arg2, arg3 );
}

void primitiveOp_intLt( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, int32_t ) < VAL( %s, int32_t );\n", cb.tabs, arg1, arg2, arg3 );
}

void primitiveOp_intLte( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, int32_t ) <= VAL( %s, int32_t );\n", cb.tabs, arg1, arg2, arg3 );
}