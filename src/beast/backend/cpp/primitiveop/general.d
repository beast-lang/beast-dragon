module beast.backend.cpp.primitiveop.general;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_zeroInitCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		codeResult_.formattedWrite( "%smemset( %s, 0, %s );\n", tabs, resultVarName_, inst.dataType.instanceSize );
	}
}

void primitiveOp_primitiveCopyCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		string arg1 = resultVarName_;

		inst.buildCode( cb );
		codeResult_.formattedWrite( "%smemcpy( %s, %s, %s );\n", tabs, resultVarName_, arg1, inst.dataType.instanceSize );
	}
}

void primitiveOp_noopDtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	inst.buildCode( cb );
	cb.codeResult_.formattedWrite( "%s// %s DTOR\n", cb.tabs, cb.resultVarName_ );
}
