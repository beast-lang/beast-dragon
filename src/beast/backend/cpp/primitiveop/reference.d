module beast.backend.cpp.primitiveop.reference;

import beast.backend.cpp.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

void primitiveOp_refCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		size_t data = 0;

		inst.buildCode( cb );
		codeResult_.formattedWrite( "%sVAL( %s, void* ) = 0;\n", tabs, resultVarName_ );
	}
}

void primitiveOp_refCopyCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const string arg1 = resultVarName_;

		inst.buildCode( cb );
		codeResult_.formattedWrite( "%sVAL( %s, void* ) = VAL( %s, void* );\n", tabs, resultVarName_, arg1 );
	}
}

void primitiveOp_refRefCtor( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const string arg1 = resultVarName_;

		inst.buildCode( cb );
		codeResult_.formattedWrite( "%sVAL( %s, void* ) = %s;\n", tabs, resultVarName_, arg1 );
	}
}