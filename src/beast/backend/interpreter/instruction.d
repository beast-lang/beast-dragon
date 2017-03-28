module beast.backend.interpreter.instruction;

import beast.backend.toolkit;
import beast.code.data.function_.rt;
import beast.util.enumassoc;
import beast.core.project.codelocation;
import beast.core.error.error;

struct Instruction {

	public:
		enum I {
			noOp, /// Does basically nothing
			noReturnError, /// () Throws an error - function did not exit using return statement
			printError, /// () Throws an error - cannot print to stdout at compile time
			assert_, /// (condition: ptr) If condition is false (evaluated as bool), reports an error

			allocLocal, /// (bpOffset : dd, bytes : dd) Allocates memory for a local variable
			skipAlloc, /// (bpOffset: dd) Do not allocate memory for local variable (but increase stack offset)
			popScope, /// (targetBpOffset: dd) Deallocates all variables on the stack above targetBpOffset
			call, /// (function : func) Function call (arguments are passed on the stack in order [RETURN VALUE] [OP3] [OP2] [OP1] [CONTEXT PTR - always (even if null)])
			ret, /// () returns from a function call

			mov, /// (target : ptr, source : ptr, bytes : dd) Copies memory from one place to another
			movConst, /// (target: ptr, source: dd, bytes: dd) Saves given data into memory
			zero, /// (target: ptr, bytes: dd) Zeroes given memory
			stAddr, /// (target: ptr, source: ptr) Stores address of source into the target

			jmpTrue, /// (target: jt, condition: ptr) Jumps to given instruction (ID/index) when condition (read as 1byte boolean) is true
			jmpFalse, /// (target: jt, condition: ptr) Jumps to given instruction (ID/index) when condition (read as 1byte boolean) is false
			jmp, /// (target: jt) Jumps to given instruction (ID/index)

			boolNot, /// (target: ptr, source: ptr) Boolean not operation

			intAdd32, /// (target: ptr, op1: ptr, op2: ptr) target <= op1 + op2
			intSub32, /// (target: ptr, op1: ptr, op2: ptr) target <= op1 - op2
		}

	public:
		this( I i, InstructionOperand op1 = InstructionOperand( ), InstructionOperand op2 = InstructionOperand( ), InstructionOperand op3 = InstructionOperand( ) ) {
			this.i = i;
			op[ 0 ] = op1;
			op[ 1 ] = op2;
			op[ 2 ] = op3;

			codeLocation = getCodeLocation();
		}

	public:
		I i;
		InstructionOperand[ 3 ] op;
		CodeLocation codeLocation;

	public:
		ref InstructionOperand op1( ) {
			return op[ 0 ];
		}

		ref InstructionOperand op2( ) {
			return op[ 1 ];
		}

		ref InstructionOperand op3( ) {
			return op[ 2 ];
		}

	public:
		string identificationString( ) {
			assert( i in enumAssocInvert!I );

			string ops;

			if ( op[ 0 ].type != InstructionOperand.Type.unused ) {
				ops ~= " %s".format( op[ 0 ].identificationString );

				if ( op[ 1 ].type != InstructionOperand.Type.unused ) {
					ops ~= ", %s".format( op[ 1 ].identificationString );

					if ( op[ 2 ].type != InstructionOperand.Type.unused )
						ops ~= ", %s".format( op[ 2 ].identificationString );
				}
				else {
					assert( op[ 2 ].type == InstructionOperand.Type.unused );
				}
			}
			else {
				assert( op[ 1 ].type == InstructionOperand.Type.unused );
				assert( op[ 2 ].type == InstructionOperand.Type.unused );
			}

			return "%s%s".format( enumAssocInvert!I[ i ], ops );
		}

}

struct InstructionOperand {

	public:
		enum Type {
			unused,

			heapRef, /// Direct pointer to a memory
			stackRef, /// Offset from base pointer

			refHeapRef, /// Reference in a static memory
			refStackRef, /// Reference on a stack

			directData,
			functionPtr,
			jumpTarget,

			placeholder, /// This should not appear in the resulting code
		}

	public:
		Type type;
		union {
			/// When type == heapRef || refHeapRef
			MemoryPtr heapLocation;

			/// When type == stackRef || refStackRef
			size_t basePointerOffset;

			/// When type == directData
			size_t directData;

			/// When type == functionPtr
			Symbol_RuntimeFunction functionPtr;

			/// When type == jumpTarget
			size_t jumpTarget;
		}

	public:
		string identificationString( ) {
			final switch ( type ) {

			case Type.unused:
				return "(unused)";

			case Type.heapRef:
				return "%#x".format( heapLocation.val );

			case Type.stackRef: {
					int bpo = cast( int ) basePointerOffset;
					return bpo >= 0 ? "BP+%s".format( bpo ) : "BP-%s".format( -bpo );
				}

			case Type.refHeapRef:
				return "#%#x".format( heapLocation.val );

			case Type.refStackRef: {
					int bpo = cast( int ) basePointerOffset;
					return bpo >= 0 ? "#BP+%s".format( bpo ) : "#BP-%s".format( -bpo );
				}

			case Type.directData:
				return "%s".format( directData );

			case Type.functionPtr:
				return "@%s".format( functionPtr.identificationString );

			case Type.jumpTarget:
				return "@%s".format( jumpTarget );

			case Type.placeholder:
				return "(placeholder)";

			}
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

InstructionOperand iopPlaceholder( ) {
	return InstructionOperand( InstructionOperand.Type.placeholder );
}
