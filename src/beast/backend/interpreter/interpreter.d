module beast.backend.interpreter.interpreter;

import beast.backend.toolkit;
import beast.backend.interpreter.instruction;
import std.typecons : Typedef;
import std.meta : aliasSeqOf;
import std.range : iota;

//debug = interpreter;

final class Interpreter {

	public:
		static void executeFunction( Symbol_RuntimeFunction func, MemoryPtr resultPtr, MemoryPtr ctxPtr, MemoryPtr[ ] args ) {
			assert( resultPtr.isNull == ( func.returnType is coreLibrary.type.Void ) );
			assert( args.length == func.parameters.length );

			auto ir = scoped!Interpreter;
			Interpreter pr = ir;

			ir.stack ~= resultPtr;
			ir.stack ~= args;
			ir.stack ~= ctxPtr;

			ir.executeInstruction( Instruction.I.call, func.iopFuncPtr );
			ir.run( );
		}

	public:
		this( ) {
			currentFrame.instructionPointer = 1;
		}

	public:
		void executeInstruction( Instruction.I i, InstructionOperand op1 = InstructionOperand( ), InstructionOperand op2 = InstructionOperand( ), InstructionOperand op3 = InstructionOperand( ) ) {
			Instruction instr = Instruction( i, op1, op2, op3 );
			executeInstruction( instr );
		}

		void executeInstruction( ref Instruction instr ) {
			debug ( interpreter ) {
				import std.stdio : writefln;

				writefln( ":%4s\t@%4s\t%s", execId, currentFrame.instructionPointer - 1, instr.identificationString );
				execId++;
			}

			mixin( ( ) { //
				import std.array : appender;

				auto result = appender!string;
				result ~= "final switch( instr.i ) {\n";

				foreach ( instrName; __traits( derivedMembers, Instruction.I ) )
					result ~= "case Instruction.I.%s: executeInstruction!\"%s\"( instr ); break;\n".format( instrName, instrName );

				result ~= "}";
				return result.data;
			}( ) );
		}

	public:
		/// Starts executing instructions until it hits return to null function
		void run( ) {
			while ( currentFrame.sourceBytecode ) {
				auto ip = currentFrame.instructionPointer;
				currentFrame.instructionPointer++;

				executeInstruction( currentFrame.sourceBytecode[ ip ] );
			}
		}

	private:
		pragma( inline ) void executeInstruction( string instructionName )( ref Instruction instr ) {
			// Calls appropriate function from beast.backend.interpreter.op

			static import beast.backend.interpreter.op;
			import std.traits : Parameters;

			mixin( "alias ifunc = beast.backend.interpreter.op.op_%s;".format( instructionName ) );

			alias Args = Parameters!ifunc[ 1 .. $ ];

			Args args;

			foreach ( i; aliasSeqOf!( iota( 0, args.length ) ) )
				args[ i ] = convertOperand!( Args[ i ] )( instr.op[ i ] );

			ifunc( this, args );
		}

	private:
		pragma( inline ) auto convertOperand( Target : MemoryPtr )( ref InstructionOperand op ) {
			switch ( op.type ) {

			case InstructionOperand.Type.heapRef:
				return op.heapLocation;

			case InstructionOperand.Type.stackRef:
				assert( currentFrame.basePointer + op.basePointerOffset < stack.length, "Variable not on stack" );
				return stack[ currentFrame.basePointer + op.basePointerOffset ];

			default:
				assert( 0, "Invalid operand type '%s', expected memoryPtr".format( op.type ) );

			}
		}

		pragma( inline ) auto convertOperand( Target : size_t )( ref InstructionOperand op ) {
			switch ( op.type ) {

			case InstructionOperand.Type.directData:
				return op.directData;

			default:
				assert( 0, "Invalid operand type '%s', expected directData".format( op.type ) );

			}
		}

		pragma( inline ) auto convertOperand( Target : JumpTarget )( ref InstructionOperand op ) {
			switch ( op.type ) {

			case InstructionOperand.Type.jumpTarget:
				return JumpTarget( op.jumpTarget );

			default:
				assert( 0, "Invalid operand type '%s', expected jumpTarget".format( op.type ) );

			}
		}

		pragma( inline ) auto convertOperand( Target : Symbol_RuntimeFunction )( ref InstructionOperand op ) {
			switch ( op.type ) {

			case InstructionOperand.Type.functionPtr:
				return op.functionPtr;

			default:
				assert( 0, "Invalid operand type '%s', expected functionPtr".format( op.type ) );

			}
		}

	package:
		/// Stack of function call records
		StackFrame[ ] callStack;
		StackFrame currentFrame;
		/// Stack of local variables
		MemoryPtr[ ] stack;
		debug ( interpreter ) size_t execId;

	package:
		alias JumpTarget = Typedef!( size_t, 0, "beast.interpreter.jumpTarget" );
		struct StackFrame {
			size_t basePointer;

			/// Bytecode that is currently interpreted (functions have separate bytecodes)
			Instruction[ ] sourceBytecode;

			/// Instruction that should be executed after a return from this stack
			size_t instructionPointer;
		}

}
