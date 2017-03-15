module beast.backend.cpp.primitiveop.int_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_intCtor( DataScope scope_, CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
	cb.codeResult_.formattedWrite( "%s*( (int32_t*) %s ) = 0;\n", cb.tabs, inst );
}

void primitiveOp_intCopyCtor( DataScope scope_, CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
	cb.codeResult_.formattedWrite( "%s*( (int32_t*) %s ) = *( (int32_t*) %s );\n", cb.tabs, inst, args[ 0 ] );
}