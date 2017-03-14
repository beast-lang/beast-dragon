module beast.backend.cpp.primitiveop.bool_;

import beast.backend.cpp.primitiveop.toolkit;

string primitiveOp_boolCtor( CodeBuilder_Cpp cb, string inst, string[] args ) {
	cb.codeResult_.formattedWrite( "%s( (bool*) %s ) = false;", cb.tabs, inst );
	return null;
}
