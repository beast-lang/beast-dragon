module beast.backend.ctime.primitiveop.bool_;

import beast.backend.ctime.primitiveop.toolkit;

void primitiveOp_boolOr( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		const MemoryPtr result = result_;

		inst.buildCode( cb );
		if ( result_.readPrimitive!bool() ) {
			result.writePrimitive( true );
			result_ = result;
			return;
		}

		args[ 1 ].buildCode( cb );
		result.write( result_, 1 );
		result_ = result;
	}
}

void primitiveOp_boolAnd( CB cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		const MemoryPtr result = result_;

		inst.buildCode( cb );
		if ( !result_.readPrimitive!bool() ) {
			result.writePrimitive( false );
			result_ = result;
			return;
		}

		args[ 1 ].buildCode( cb );
		result.write( result_, 1 );
		result_ = result;
	}
}
