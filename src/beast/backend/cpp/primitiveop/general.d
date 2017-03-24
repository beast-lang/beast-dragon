module beast.backend.cpp.primitiveop.general;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_memZero( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );

		size_t instSize = inst.dataType.instanceSize;
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

void primitiveOp_memCpy( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		string arg1 = resultVarName_;

		inst.buildCode( cb );

		size_t instSize = inst.dataType.instanceSize;
		if ( instSize == 1 )
			codeResult_.formattedWrite( "%sVAL( %s, uint8_t ) = VAL( %s, uint8_t );\n", tabs, resultVarName_, arg1 );
		else if ( instSize == 2 )
			codeResult_.formattedWrite( "%sVAL( %s, uint16_t ) = VAL( %s, uint8_t );\n", tabs, resultVarName_, arg1 );
		else if ( instSize == 4 )
			codeResult_.formattedWrite( "%sVAL( %s, uint32_t ) = VAL( %s, uint8_t );\n", tabs, resultVarName_, arg1 );
		else
			codeResult_.formattedWrite( "%smemcpy( %s, %s, %s );\n", tabs, resultVarName_, arg1, inst.dataType.instanceSize );
	}
}

void primitiveOp_noopDtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	inst.buildCode( cb );
	cb.codeResult_.formattedWrite( "%s// %s DTOR\n", cb.tabs, cb.resultVarName_ );
}

void primitiveOp_print( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		auto arg1 = args[ 0 ];
		auto dataType = arg1.dataType;

		arg1.buildCode( cb );

		if ( dataType is coreLibrary.type.Bool )
			codeResult_.formattedWrite( "%sprintf( \"%%i\", VAL( %s, bool ) );\n", tabs, resultVarName_ );
		else
			assert( 0, "Print not implemented for " ~ arg1.identificationString );
	}
}

void primitiveOp_assert_( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 0 ].buildCode( cb );
		codeResult_.formattedWrite( "%sassert( VAR( %s, bool ) );\n", tabs, resultVarName_ );
	}
}
