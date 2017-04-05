module beast.backend.cpp.primitiveop.general;

import beast.backend.cpp.primitiveop.toolkit;

pragma( inline ) string memType( size_t instanceSize ) {
	switch ( instanceSize ) {

	case 0:
		assert( 0 );

	case 1:
		return "uint8_t";

	case 2:
		return "uint16_t";

	case 4:
		return "uint32_t";

	default:
		return null;

	}
}

void primitiveOp_memZero( CB cb, T t, Op arg1 ) {
	with ( cb ) {
		enforceOperandNotCtime( arg1 );

		if ( string mt = memType( t.instanceSize ) )
			codeResult_.formattedWrite( "%sVAL( %s, %s ) = 0;\n", tabs, arg1, mt );
		else
			codeResult_.formattedWrite( "%smemset( %s, 0, %s );\n", tabs, arg1 );
	}
}

void primitiveOp_memCpy( CB cb, T t, Op arg1, Op arg2 ) {
	with ( cb ) {
		enforceOperandNotCtime( arg1 );

		if ( string mt = memType( t.instanceSize ) )
			codeResult_.formattedWrite( "%sVAL( %s, %s ) = VAL( %s, %s );\n", tabs, arg1, mt, arg2, mt );
		else
			codeResult_.formattedWrite( "%smemcpy( %s, %s, %s );\n", tabs, arg1, arg2, t.instanceSize );
	}
}

void primitiveOp_memEq( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	with ( cb ) {
		enforceOperandNotCtime( arg1 );

		if ( string mt = memType( t.instanceSize ) )
			codeResult_.formattedWrite( "%sVAL( %s, bool ) = ( VAL( %s, %s ) == VAL( %s, %s ) );\n", tabs, arg1, arg2, mt, arg3, mt );
		else
			codeResult_.formattedWrite( "%VAL( %s, bool ) = ( memcmp( %s, %s, %s ) == 0 );\n", tabs, arg1, arg2, arg3, t.instanceSize );
	}
}

void primitiveOp_memNeq( CB cb, T t, Op arg1, Op arg2, Op arg3 ) {
	with ( cb ) {
		enforceOperandNotCtime( arg1 );

		if ( string mt = memType( t.instanceSize ) )
			codeResult_.formattedWrite( "%sVAL( %s, bool ) = ( VAL( %s, %s ) != VAL( %s, %s ) );\n", tabs, arg1, arg2, mt, arg3, mt );
		else
			codeResult_.formattedWrite( "%VAL( %s, bool ) = ( memcmp( %s, %s, %s ) != 0 );\n", tabs, arg1, arg2, arg3, t.instanceSize );
	}
}

void primitiveOp_noopDtor( CB cb, T t, Op arg1 ) {
	cb.enforceOperandNotCtime( arg1 );
	cb.codeResult_.formattedWrite( "%s// %s DTOR\n", cb.tabs, arg1 );
}

void primitiveOp_print( CB cb, T t, Op arg1 ) {
	with ( cb ) {
		if ( t is coreLibrary.type.Bool )
			codeResult_.formattedWrite( "%sprintf( \"%%i\", VAL( %s, bool ) );\n", tabs, arg1 );
		else if ( t is coreLibrary.type.Int32 )
			codeResult_.formattedWrite( "%sprintf( \"%%i\", VAL( %s, int32_t ) );\n", tabs, arg1 );
		else
			assert( 0, "Print not implemented for " ~ t.identificationString );
	}
}

void primitiveOp_assert_( CB cb, T t, Op arg1 ) {
	cb.codeResult_.formattedWrite( "%sassert( VAL( %s, bool ) );\n", cb.tabs, arg1 );
}
