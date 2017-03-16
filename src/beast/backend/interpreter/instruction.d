module beast.backend.interpreter.instruction;

import beast.code.memory.ptr;
import beast.code.data.function_.rt;

struct Instruction {

	public:
		enum I {
			noOp, /// Does basically nothing

			allocLocal, /// (bpOffset : dd, bytes : dd) Allocates memory for a local variable
			call, /// (function : func) Function call (arguments are passed on the stack in order [RETURN VALUE] [OP3] [OP2] [OP1] [CONTEXT PTR - always (even if null)])
			ret, /// () returns from a function call

			mov, /// (target : ptr, source : ptr, bytes : dd) Copies memory from one place to another
			movConst, /// (target: ptr, source: dd, bytes: dd) Saves given data into memory
		}

	public:
		this( I i, InstructionOperand op1 = InstructionOperand( ), InstructionOperand op2 = InstructionOperand( ), InstructionOperand op3 = InstructionOperand( ) ) {
			this.i = i;
			op[ 0 ] = op1;
			op[ 1 ] = op2;
			op[ 2 ] = op3;
		}

	public:
		I i;
		InstructionOperand[ 3 ] op;

}

struct InstructionOperand {

	public:
		enum Type {
			unused,
			heapRef,
			stackRef,
			directData,
			functionPtr,
		}

	public:
		Type type;
		union {
			/// When type == heapRef
			MemoryPtr heapLocation;

			/// When type == stackRef
			size_t basePointerOffset;

			/// When type == directData
			size_t directData;

			/// When type == functionPtr
			Symbol_RuntimeFunction functionPtr;
		}

}

InstructionOperand iopBpOffset( size_t offset ) {
	auto result = InstructionOperand( InstructionOperand.Type.stackRef );
	result.basePointerOffset = offset;
	return result;
}

InstructionOperand iopPtr( MemoryPtr ptr ) {
	auto result = InstructionOperand( InstructionOperand.Type.heapRef );
	result.heapLocation = ptr;
	return result;
}

InstructionOperand iopLiteral( size_t data ) {
	auto result = InstructionOperand( InstructionOperand.Type.directData );
	result.directData = data;
	return result;
}

InstructionOperand iopFuncPtr( Symbol_RuntimeFunction func ) {
	auto result = InstructionOperand( InstructionOperand.Type.functionPtr );
	result.functionPtr = func;
	return result;
}
