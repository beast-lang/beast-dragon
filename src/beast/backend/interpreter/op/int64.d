module beast.backend.interpreter.op.int64;

import beast.backend.interpreter.op.toolkit;

//debug = interpreter;

debug (interpreter) {
	import std.stdio : writefln;
}

pragma(inline):

void op_intAdd64(Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2) {
	target.writePrimitive(op1.readPrimitive!long + op2.readPrimitive!long);

	debug (interpreter)
		writefln("%#x (%s) + %#x (%s) => %#x (%s)", op1.val, op1.readPrimitive!long, op2.val, op2.readPrimitive!long, target.val, target.readPrimitive!long);
}

void op_intAddConst64(Interpreter ir, MemoryPtr target, MemoryPtr op1, size_t op2) {
	target.writePrimitive(op1.readPrimitive!long + op2);

	debug (interpreter)
		writefln("%#x (%s) + (%s) => %#x (%s)", op1.val, op1.readPrimitive!long, op2, target.val, target.readPrimitive!long);
}

void op_intSub64(Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2) {
	target.writePrimitive(op1.readPrimitive!long - op2.readPrimitive!long);

	debug (interpreter)
		writefln("%#x (%s) - %#x (%s) => %#x (%s)", op1.val, op1.readPrimitive!long, op2.val, op2.readPrimitive!long, target.val, target.readPrimitive!long);
}

void op_intMult64(Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2) {
	target.writePrimitive(op1.readPrimitive!long * op2.readPrimitive!long);

	debug (interpreter)
		writefln("%#x (%s) * %#x (%s) => %#x (%s)", op1.val, op1.readPrimitive!long, op2.val, op2.readPrimitive!long, target.val, target.readPrimitive!long);
}

void op_intDiv64(Interpreter ir, MemoryPtr target, MemoryPtr op1, MemoryPtr op2) {
	target.writePrimitive(op1.readPrimitive!long / op2.readPrimitive!long);

	debug (interpreter)
		writefln("%#x (%s) / %#x (%s) => %#x (%s)", op1.val, op1.readPrimitive!long, op2.val, op2.readPrimitive!long, target.val, target.readPrimitive!long);
}

void op_intCmp64(Interpreter ir, MemoryPtr op1, MemoryPtr op2) {
	auto tmp = op1.readPrimitive!long - op2.readPrimitive!long;
	ir.flagsRegister_setFlag(ir.RFlag.less, tmp < 0);
	ir.flagsRegister_setFlag(ir.RFlag.equals, tmp == 0);

	debug (interpreter)
		writefln("%#x (%s) cmp %#x (%s) => %b", op1.val, op1.readPrimitive!long, op2.val, op2.readPrimitive!long, ir.flagsRegister);
}
