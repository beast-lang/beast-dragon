module beast.backend.cpp.primitiveop.bool_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_boolCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		codeResult_.formattedWrite( "%sVAL( %s, bool ) = false;\n", tabs, codeResult_ );
	}
}

void primitiveOp_boolCopyCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		string arg1 = resultVarName_;

		inst.buildCode( cb );
		codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, bool );\n", tabs, resultVarName_, arg1 );
	}
}

void primitiveOp_boolOr( CB cb, DataEntity inst, DataEntity[ ] args ) { 
	with ( cb ) {
		const string result = resultVarName_;

		inst.buildCode( cb );
		codeResult_.formattedWrite( "%sif( VAL( %s, bool ) )\n%sVAL( %s, bool ) = true;\n%selse {\n", tabs, resultVarName_, tabs( 1 ), result, tabs );
		pushScope( );

		args[ 1 ].buildCode( cb );
		codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, bool );\n", tabs, result, resultVarName_ );

		popScope( );
		codeResult_.formattedWrite( "%s}\n", tabs );

		resultVarName_ = result;
	}
}

void primitiveOp_boolAnd( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		const string result = resultVarName_;

		inst.buildCode( cb );
		codeResult_.formattedWrite( "%sif( VAL( %s, bool ) ) {\n", tabs, resultVarName_, tabs( 1 ), result, tabs );
		pushScope( );

		args[ 1 ].buildCode( cb );
		codeResult_.formattedWrite( "%sVAL( %s, bool ) = VAL( %s, bool );\n", tabs, result, resultVarName_ );

		popScope( );
		codeResult_.formattedWrite( "%s} else\n%sVAL( %s, bool ) = false;\n", tabs, tabs( 1 ), result );

		resultVarName_ = result;
	}
}
