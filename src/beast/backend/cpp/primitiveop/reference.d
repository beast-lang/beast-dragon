module beast.backend.cpp.primitiveop.reference;

import beast.backend.cpp.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_getAddr( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		const string arg1v = resultVarName_;

		arg2( cb );
		codeResult_.formattedWrite( "%sVAL( %s, void* ) = %s;\n", tabs, arg1v, resultVarName_ );
	}
}

void primitiveOp_dereference( CB cb, T argT, F arg1, F arg2, F arg3 ) {
	with ( cb ) {
		arg1( cb );
		resultVarName_ = "*( ( unsigned char ** ) ( %s ) )".format( resultVarName_ );
	}
}
