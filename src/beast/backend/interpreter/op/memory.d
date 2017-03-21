module beast.backend.interpreter.op.memory;

import beast.backend.interpreter.op.toolkit;

//debug = instructions;

debug ( instructions ) {
	import std.stdio : writefln;
}

pragma( inline ):

	// MEMORY OPERATIONS
	void op_mov( Interpreter ir, MemoryPtr op1, MemoryPtr op2, size_t bytes ) {
		op1.write( op2, bytes );

		debug ( instructions )
			writefln( "\t\t  %#x => %#x\t%s", op2.val, op1.val, op1.read( bytes ) );
	}

	void op_movConst( Interpreter ir, MemoryPtr op1, size_t data, size_t bytes ) {
		version ( BigEndian ) static assert( 0 );
		op1.write( &data, bytes );

		debug ( instructions )
			writefln( "\t\t  => %#x\t%s", op1.val, cast( const( ubyte )[ ] )( cast( void* )&data )[ 0 .. bytes ] );
	}