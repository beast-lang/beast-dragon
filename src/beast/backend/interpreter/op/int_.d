module beast.backend.interpreter.op.int_;

import beast.backend.interpreter.op.toolkit;

//debug = interpreter;

debug ( interpreter ) {
	import std.stdio : writefln;
}

pragma( inline ):

	void op_intAdd32( Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2 ) {
		target.writePrimitive( op1.readPrimitive!int + op2.readPrimitive!int );
	}

	void op_intSub32( Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2 ) {
		target.writePrimitive( op1.readPrimitive!int - op2.readPrimitive!int );
	}
