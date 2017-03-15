module beast.backend.cpp.primitiveop.int_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_intCtor( CodeBuilder_Cpp cb, string inst, string[ ] args ) {
	cb.codeResult_.formattedWrite( "%s*( (int32_t*) %s ) = 0;\n", cb.tabs, inst );
}

void primitiveOp_intCopyCtor( CodeBuilder_Cpp cb, string inst, string[ ] args ) {
	cb.codeResult_.formattedWrite( "%s*( (int32_t*) %s ) = *( (int32_t*) %s );\n", cb.tabs, inst, args[ 0 ] );
}