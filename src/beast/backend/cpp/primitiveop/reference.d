module beast.backend.cpp.primitiveop.reference;

import beast.backend.cpp.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_getAddr( CB cb, T t, Op arg1, Op arg2 ) {
	cb.codeResult_.formattedWrite( "%sVAL( %s, void* ) = %s;\n", cb.tabs, arg1, arg2 );
}

void primitiveOp_dereference( CB cb, T t, Op arg1 ) {
	cb.resultVarName_ = "*( ( unsigned char ** ) ( %s ) )".format( arg1 );
}
