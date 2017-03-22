module beast.backend.interpreter.op.memory;

import beast.backend.interpreter.op.toolkit;
import beast.code.hwenv.hwenv;
import std.range : repeat;

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

	void op_zero( Interpreter ir, MemoryPtr op1, size_t bytes ) {
		op1.write( repeat( cast( ubyte ) 0, bytes ).array );

		debug ( instructions )
			writefln( "\t\t  0 => %#x (%s)", op1.val, bytes );
	}

	void op_stAddr( Interpreter ir, MemoryPtr op1, MemoryPtr op2 ) {
		op1.write( &op2, hardwareEnvironment.effectivePointerSize );

		debug ( instructions )
			writefln( "\t\t  @%#x => %#x", op2.val, op1.val );
	}
