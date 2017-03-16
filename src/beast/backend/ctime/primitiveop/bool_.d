module beast.backend.ctime.primitiveop.bool_;

import beast.backend.ctime.primitiveop.toolkit;

void primitiveOp_boolCtor( CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb );
		result_.writePrimitive( false );
	}
}

void primitiveOp_boolCopyCtor( CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb );
		const MemoryPtr arg1 = result_;

		inst.buildCode( cb );
		result_.write( arg1, 1 );
	}
}

void primitiveOp_boolOr( CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
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

void primitiveOp_boolAnd( CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
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
