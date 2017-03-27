module beast.backend.interpreter.primitiveop.toolkit;

public {
	import beast.backend.toolkit;
	import beast.backend.interpreter.codebuilder : CodeBuilder_Interpreter;
	import beast.backend.interpreter.instruction : Instruction, InstructionOperand, iopPtr, iopLiteral, iopPlaceholder;
	import std.format : formattedWrite;
}

alias I = Instruction.I;
alias CB = CodeBuilder_Interpreter;
alias T = Symbol_Type;
alias F = CodeBuilder.ExprFunction;