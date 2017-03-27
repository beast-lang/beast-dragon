module beast.backend.cpp.primitiveop.general;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_memZero( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );

		size_t instSize = argT.instanceSize;
		if ( instSize == 1 )
			codeResult_.formattedWrite( "%sVAL( %s, uint8_t ) = 0;\n", tabs, resultVarName_ );
		else if ( instSize == 2 )
			codeResult_.formattedWrite( "%sVAL( %s, uint16_t ) = 0;\n", tabs, resultVarName_ );
		else if ( instSize == 4 )
			codeResult_.formattedWrite( "%sVAL( %s, uint32_t ) = 0;\n", tabs, resultVarName_ );
		else
			codeResult_.formattedWrite( "%smemset( %s, 0, %s );\n", tabs, resultVarName_ );
	}
}

void primitiveOp_memCpy( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		string arg1v = resultVarName_;

		arg2( cb );

		size_t instSize = argT.instanceSize;
		if ( instSize == 1 )
			codeResult_.formattedWrite( "%sVAL( %s, uint8_t ) = VAL( %s, uint8_t );\n", tabs, arg1v, resultVarName_ );
		else if ( instSize == 2 )
			codeResult_.formattedWrite( "%sVAL( %s, uint16_t ) = VAL( %s, uint16_t );\n", tabs, arg1v, resultVarName_ );
		else if ( instSize == 4 )
			codeResult_.formattedWrite( "%sVAL( %s, uint32_t ) = VAL( %s, uint32_t );\n", tabs, arg1v, resultVarName_ );
		else
			codeResult_.formattedWrite( "%smemcpy( %s, %s, %s );\n", tabs, arg1v, resultVarName_, instSize );
	}
}

void primitiveOp_noopDtor( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	arg1( cb );
	cb.codeResult_.formattedWrite( "%s// %s DTOR\n", cb.tabs, cb.resultVarName_ );
}

void primitiveOp_print( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );

		if ( argT is coreLibrary.type.Bool )
			codeResult_.formattedWrite( "%sprintf( \"%%i\", VAL( %s, bool ) );\n", tabs, resultVarName_ );
		else
			assert( 0, "Print not implemented for " ~ argT.identificationString );
	}
}

void primitiveOp_assert_( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		codeResult_.formattedWrite( "%sassert( VAR( %s, bool ) );\n", tabs, resultVarName_ );
	}
}
