module beast.backend.ctime.primitiveop.bool_;

import beast.backend.ctime.primitiveop.toolkit;

void primitiveOp_boolCtor( DataScope scope_, CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb, scope_ );
		result_.writePrimitive( false );
	}
}

void primitiveOp_boolCopyCtor( DataScope scope_, CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb, scope_ );
		const MemoryPtr arg1 = result_;

		inst.buildCode( cb, scope_ );
		result_.write( arg1, 1 );
	}
}

void primitiveOp_boolOr( DataScope scope_, CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		const MemoryPtr result = result_;

		inst.buildCode( cb, scope_ );
		if ( result_.readPrimitive!bool() ) {
			result.writePrimitive( true );
			result_ = result;
			return;
		}

		args[ 1 ].buildCode( cb, scope_ );
		result.write( result_, 1 );
		result_ = result;
	}
}

void primitiveOp_boolAnd( DataScope scope_, CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		const MemoryPtr result = result_;

		inst.buildCode( cb, scope_ );
		if ( !result_.readPrimitive!bool() ) {
			result.writePrimitive( false );
			result_ = result;
			return;
		}

		args[ 1 ].buildCode( cb, scope_ );
		result.write( result_, 1 );
		result_ = result;
	}
}
