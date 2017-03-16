module beast.backend.cpp.primitiveop.general;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_noopDtor( CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
	inst.buildCode( cb );
	cb.codeResult_.formattedWrite( "%s// %s DTOR\n", cb.tabs, cb.resultVarName_ );
}
