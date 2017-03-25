module beast.backend.cpp.primitiveop.reference;

import beast.backend.cpp.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_storeAddr( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const string arg1 = resultVarName_;

		inst.buildCode( cb );
		codeResult_.formattedWrite( "%sVAL( %s, void* ) = %s;\n", tabs, resultVarName_, arg1 );
	}
}

void primitiveOp_loadAddr( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		resultVarName_ = "*( ( unsigned char ** ) ( %s ) )".format( resultVarName_ );
	}
}
