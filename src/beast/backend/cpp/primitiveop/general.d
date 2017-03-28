module beast.backend.cpp.primitiveop.general;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_memZero( CB cb, T t, Op arg1 ) {
	with ( cb ) {
		size_t instSize = t.instanceSize;
		if ( instSize == 1 )
			codeResult_.formattedWrite( "%sVAL( %s, uint8_t ) = 0;\n", tabs, arg1 );
		else if ( instSize == 2 )
			codeResult_.formattedWrite( "%sVAL( %s, uint16_t ) = 0;\n", tabs, arg1 );
		else if ( instSize == 4 )
			codeResult_.formattedWrite( "%sVAL( %s, uint32_t ) = 0;\n", tabs, arg1 );
		else
			codeResult_.formattedWrite( "%smemset( %s, 0, %s );\n", tabs, arg1 );
	}
}

void primitiveOp_memCpy( CB cb, T t, Op arg1, Op arg2 ) {
	with ( cb ) {
		size_t instSize = t.instanceSize;
		if ( instSize == 1 )
			codeResult_.formattedWrite( "%sVAL( %s, uint8_t ) = VAL( %s, uint8_t );\n", tabs, arg1, arg2 );
		else if ( instSize == 2 )
			codeResult_.formattedWrite( "%sVAL( %s, uint16_t ) = VAL( %s, uint16_t );\n", tabs, arg1, arg2 );
		else if ( instSize == 4 )
			codeResult_.formattedWrite( "%sVAL( %s, uint32_t ) = VAL( %s, uint32_t );\n", tabs, arg1, arg2 );
		else
			codeResult_.formattedWrite( "%smemcpy( %s, %s, %s );\n", tabs, arg1, arg2, instSize );
	}
}

void primitiveOp_noopDtor( CB cb, T t, Op arg1 ) {
	cb.codeResult_.formattedWrite( "%s// %s DTOR\n", cb.tabs, arg1 );
}

void primitiveOp_print( CB cb, T t, Op arg1 ) {
	with ( cb ) {
		if ( t is coreLibrary.type.Bool )
			codeResult_.formattedWrite( "%sprintf( \"%%i\", VAL( %s, bool ) );\n", tabs, arg1 );
		else if ( t is coreLibrary.type.Int )
			codeResult_.formattedWrite( "%sprintf( \"%%i\", VAL( %s, int32_t ) );\n", tabs, arg1 );
		else
			assert( 0, "Print not implemented for " ~ t.identificationString );
	}
}

void primitiveOp_assert_( CB cb, T t, Op arg1 ) {
	cb.codeResult_.formattedWrite( "%sassert( VAL( %s, bool ) );\n", cb.tabs, arg1 );
}
