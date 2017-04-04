module beast.backend.interpreter.op.int32;

import beast.backend.interpreter.op.toolkit;

//debug = interpreter;

debug ( interpreter ) {
	import std.stdio : writefln;
}

pragma( inline ):

	void op_intAdd32( Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2 ) {
		target.writePrimitive( op1.readPrimitive!int + op2.readPrimitive!int );

		debug ( interpreter )
			writefln( "%#x (%s) + %#x (%s) => %#x (%s)", op1.val, op1.readPrimitive!int, op2.val, op2.readPrimitive!int, target.val, target.readPrimitive!int );
	}

	void op_intAddConst32( Interpreter ir, MemoryPtr target, MemoryPtr op1, size_t op2 ) {
		target.writePrimitive( op1.readPrimitive!int + op2 );

		debug ( interpreter )
			writefln( "%#x (%s) + (%s) => %#x (%s)", op1.val, op1.readPrimitive!int, op2, target.val, target.readPrimitive!int );
	}

	void op_intSub32( Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2 ) {
		target.writePrimitive( op1.readPrimitive!int - op2.readPrimitive!int );

		debug ( interpreter )
			writefln( "%#x (%s) - %#x (%s) => %#x (%s)", op1.val, op1.readPrimitive!int, op2.val, op2.readPrimitive!int, target.val, target.readPrimitive!int );
	}

	void op_intMult32( Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2 ) {
		target.writePrimitive( op1.readPrimitive!int * op2.readPrimitive!int );

		debug ( interpreter )
			writefln( "%#x (%s) * %#x (%s) => %#x (%s)", op1.val, op1.readPrimitive!int, op2.val, op2.readPrimitive!int, target.val, target.readPrimitive!int );
	}

	void op_intDiv32( Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2 ) {
		target.writePrimitive( op1.readPrimitive!int / op2.readPrimitive!int );

		debug ( interpreter )
			writefln( "%#x (%s) / %#x (%s) => %#x (%s)", op1.val, op1.readPrimitive!int, op2.val, op2.readPrimitive!int, target.val, target.readPrimitive!int );
	}

	void op_intCmp32( Interpreter ir, MemoryPtr op1, MemoryPtr op2 ) {
		auto tmp = op1.readPrimitive!int - op2.readPrimitive!int;
		ir.flagsRegister_setFlag( ir.RFlag.less, tmp < 0 );
		ir.flagsRegister_setFlag( ir.RFlag.equals, tmp == 0 );

		debug ( interpreter )
			writefln( "%#x (%s) cmp %#x (%s) => %b", op1.val, op1.readPrimitive!int, op2.val, op2.readPrimitive!int, ir.flagsRegister );
	}
