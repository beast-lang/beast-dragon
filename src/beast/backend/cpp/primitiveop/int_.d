module beast.backend.cpp.primitiveop.int_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_intCtor( CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		cb.codeResult_.formattedWrite( "%sVAL( %s, int32_t ) = 0;\n", cb.tabs, resultVarName_ );
	}
}

void primitiveOp_intCopyCtor( CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		string arg1 = resultVarName_;

		inst.buildCode( cb );
		cb.codeResult_.formattedWrite( "%sVAL( %s, int32_t ) = VAL( %s, int32_t );\n", cb.tabs, resultVarName_, arg1 );
	}
}
