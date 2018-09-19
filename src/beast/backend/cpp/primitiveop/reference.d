module beast.backend.cpp.primitiveop.reference;

import beast.backend.cpp.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_getAddr(CB cb, T t, Op arg1, Op arg2) {
	cb.enforceOperandNotCtime(arg1);
	cb.codeResult_.formattedWrite("%sVAL( %s, void* ) = %s;\n", cb.tabs, arg1, arg2);
}

void primitiveOp_markPtr(CB cb, T t, Op arg1) {
	// Do nothing - this is ctime stuff
}

void primitiveOp_unmarkPtr(CB cb, T t, Op arg1) {
	// Do nothing - this is ctime stuff
}

void primitiveOp_malloc(CB cb, T t, Op arg1, Op arg2) {
	cb.enforceOperandNotCtime(arg1);
	cb.codeResult_.formattedWrite("%sVAL( %s, void* ) = malloc( VAL( %s, size_t ) );\n", cb.tabs, arg1, arg2);
}

void primitiveOp_free(CB cb, T t, Op arg1) {
	cb.enforceOperandNotCtime(arg1);
	cb.codeResult_.formattedWrite("%sfree( VAL( %s, void* ) );\n", cb.tabs, arg1);
}
