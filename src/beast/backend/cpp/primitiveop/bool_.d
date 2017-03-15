module beast.backend.cpp.primitiveop.bool_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_boolCtor( CodeBuilder_Cpp cb, string inst, string[ ] args ) {
	cb.codeResult_.formattedWrite( "%s*( (bool*) %s ) = false;\n", cb.tabs, inst );
}

void primitiveOp_boolCopyCtor( CodeBuilder_Cpp cb, string inst, string[ ] args ) {
	cb.codeResult_.formattedWrite( "%s*( (bool*) %s ) = *( (bool*) %s );\n", cb.tabs, inst, args[ 0 ] );
}

void primitiveOp_boolOr( CodeBuilder_Cpp cb, string inst, string[ ] args ) {
	cb.codeResult_.formattedWrite( "%s*( (bool*) %s ) = *( (bool*) %s ) || *( (bool*) %s );\n", cb.tabs, cb.resultVarName_, inst, args[ 0 ] );
}

void primitiveOp_boolAnd( CodeBuilder_Cpp cb, string inst, string[ ] args ) {
	cb.codeResult_.formattedWrite( "%s*( (bool*) %s ) = *( (bool*) %s ) && *( (bool*) %s );\n", cb.tabs, cb.resultVarName_, inst, args[ 0 ] );
}
