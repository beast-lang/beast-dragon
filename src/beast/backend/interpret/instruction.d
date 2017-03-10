module beast.backend.interpret.instruction;
import beast.code.memory.ptr;

struct Instruction {

	public:
		enum I {
			noOp, /// Does basically nothing
		}

	public:
		I i;
		InstructionOperand op1, op2, op3;

}

struct InstructionOperand {

	public:
		enum Location {
			heap,
			stack
		}

	public:
		Location location;
		union {
			/// When type == heap
			MemoryPtr heapLocation;

			/// When type == stack
			size_t basePointerOffset;
		}

}
