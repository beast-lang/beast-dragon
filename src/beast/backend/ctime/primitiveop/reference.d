module beast.backend.ctime.primitiveop.reference;

import beast.backend.ctime.primitiveop.toolkit;
import beast.code.hwenv.hwenv;

debug ( ctime ) import std.stdio : writefln;

void primitiveOp_getAddr( CB cb, T t, Op arg1, Op arg2 ) {
	arg1.write( &arg2.val, hardwareEnvironment.effectivePointerSize );

	debug ( ctime )
		writefln( "CTIME getAddr @%s => %s", arg2, arg1 );
}

void primitiveOp_markPtr( CB cb, T t, Op arg1 ) {
	memoryManager.markAsPointer( arg1 );

	debug ( ctime )
		writefln( "CTIME markPtr %s", arg1 );
}

void primitiveOp_unmarkPtr( CB cb, T t, Op arg1 ) {
	memoryManager.unmarkAsPointer( arg1 );

	debug ( ctime )
		writefln( "CTIME unmarkPtr %s", arg1 );
}

void primitiveOp_malloc( CB cb, T t, Op arg1, Op arg2 ) {
	arg1.writeMemoryPtr( memoryManager.alloc( arg2.readSizeT, MemoryBlock.Flag.dynamicallyAllocated | MemoryBlock.Flag.ctime ) );

	debug ( ctime )
		writefln( "CTIME malloc( %s ) (=%s) => %s", arg2.readSizeT, arg1.readMemoryPtr, arg1 );
}

void primitiveOp_free( CB cb, T t, Op arg1 ) {
	memoryManager.free( arg1.readMemoryPtr );

	debug ( ctime )
		writefln( "CTIME free( %s ) (=%s)", arg1, arg1.readMemoryPtr );
}
