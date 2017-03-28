module beast.backend.cpp.primitiveop.bool_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_boolNot( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		string arg1v = resultVarName_;

		arg2( cb );
		codeResult_.formattedWrite( "%sVAL( %s, bool ) = !VAL( %s, bool );\n", tabs, arg1v, resultVarName_ );
	}
}