module beast.backend.interpreter.op.comparison;

import beast.backend.interpreter.op.toolkit;
import beast.code.hwenv.hwenv;
import std.range : repeat;

//debug = interpreter;

debug (interpreter) {
	import std.stdio : writefln;
}

pragma(inline):

void op_bitsCmp(Interpreter ir, MemoryPtr op1, MemoryPtr op2, size_t bytes) {
	ir.flagsRegister_setFlag(ir.RFlag.equals, op1.read(bytes) == op2.read(bytes));

	debug (interpreter)
		writefln("%#x (%s) cmp %#x (%s) => %b", op1.val, op1.read(bytes), op2.val, op2.read(bytes), ir.flagsRegister);
}

void op_cmpEq(Interpreter ir, MemoryPtr target) {
	bool result = (ir.flagsRegister & ir.RFlag.equals) != 0;
	target.writePrimitive(result);

	debug (interpreter)
		writefln("%s => %#x", result, target.val);
}

void op_cmpNeq(Interpreter ir, MemoryPtr target) {
	bool result = !(ir.flagsRegister & ir.RFlag.equals);
	target.writePrimitive(result);

	debug (interpreter)
		writefln("%s => %#x", result, target.val);
}

void op_cmpLt(Interpreter ir, MemoryPtr target) {
	bool result = (ir.flagsRegister & ir.RFlag.less) != 0;
	target.writePrimitive(result);

	debug (interpreter)
		writefln("%s => %#x", result, target.val);
}

void op_cmpLte(Interpreter ir, MemoryPtr target) {
	bool result = (ir.flagsRegister & (ir.RFlag.less | ir.RFlag.equals)) != 0;
	target.writePrimitive(result);

	debug (interpreter)
		writefln("%s => %#x", result, target.val);
}

void op_cmpGt(Interpreter ir, MemoryPtr target) {
	bool result = !(ir.flagsRegister & (ir.RFlag.less | ir.RFlag.equals));
	target.writePrimitive(result);

	debug (interpreter)
		writefln("%s => %#x", result, target.val);
}

void op_cmpGte(Interpreter ir, MemoryPtr target) {
	bool result = !(ir.flagsRegister & ir.RFlag.less);
	target.writePrimitive(result);

	debug (interpreter)
		writefln("%s => %#x", result, target.val);
}
