module beast.backend.ctime.primitiveop.bool_;

import beast.backend.ctime.primitiveop.toolkit;

void primitiveOp_boolCtor( CodeBuilder_Ctime cb, MemoryPtr inst, MemoryPtr[ ] args ) {
	inst.writePrimitive( false );
}

void primitiveOp_boolCopyCtor( CodeBuilder_Ctime cb, MemoryPtr inst, MemoryPtr[ ] args ) {
	inst.write( args[ 0 ], 1 );
}

void primitiveOp_boolOr( CodeBuilder_Ctime cb, MemoryPtr inst, MemoryPtr[ ] args ) {
	bool data = inst.readPrimitive!bool || args[0].readPrimitive!bool;
	cb.result_.write( &data, 1 );
}
