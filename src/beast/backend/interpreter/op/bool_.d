module beast.backend.interpreter.op.bool_;

import beast.backend.interpreter.op.toolkit;

//debug = interpreter;

debug ( interpreter ) {
	import std.stdio : writefln;
}

pragma( inline ):

	void op_boolNot( Interpreter ir, MemoryPtr target, MemoryPtr source ) {
		target.writePrimitive( !source.readPrimitive!bool );
	}
