module beast.backend.cpp.primitiveop.bool_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_boolNot( CB cb, T t, Op arg1, Op arg2 ) {
	cb.codeResult_.formattedWrite( "%sVAL( %s, bool ) = !VAL( %s, bool );\n", cb.tabs, arg1, arg2 );
}
