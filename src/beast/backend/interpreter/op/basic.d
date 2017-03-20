module beast.backend.interpreter.op.basic;

import beast.backend.interpreter.op.toolkit;

//debug = instructions;

debug ( instructions ) {
	import std.stdio : writefln;
}

pragma( inline ):

	void op_noOp( Interpreter ir ) {
		// Do nothing
	}

	// ALLOCATION/DEALLOCATION
	void op_allocLocal( Interpreter ir, size_t bpOffset, size_t bytes ) {
		const size_t stackOffset = ir.currentFrame.basePointer + bpOffset;

		assert( stackOffset == ir.stack.length, "AllocLocal offset mismatch" );

		ir.stack ~= memoryManager.alloc( bytes );
	}

	void op_skipAlloc( Interpreter ir, size_t bpOffset ) {
		const size_t stackOffset = ir.currentFrame.basePointer + bpOffset;

		assert( stackOffset == ir.stack.length, "AllocLocal offset mismatch" );
		ir.stack ~= MemoryPtr( );
	}

	// JUMPS/CALLS
	void op_call( Interpreter ir, Symbol_RuntimeFunction func ) {
		with ( ir ) {
			callStack ~= currentFrame;

			currentFrame.basePointer = ir.stack.length;
			currentFrame.sourceBytecode = func.interpreterCode.bytecode;
			currentFrame.instructionPointer = 0;
		}
	}

	void op_ret( Interpreter ir ) {
		with ( ir ) {
			assert( callStack.length );

			foreach ( i; currentFrame.basePointer .. stack.length ) {
				if ( !stack[ i ].isNull )
					memoryManager.free( stack[ i ] );
			}

			currentFrame = callStack[ $ - 1 ];
			callStack.length--;
		}
	}

	void op_jmp( Interpreter ir, Interpreter.JumpTarget jt ) {
		assert( jt < ir.currentFrame.sourceBytecode.length );

		ir.currentFrame.instructionPointer = cast( size_t ) jt;
	}

	void op_jmpTrue( Interpreter ir, Interpreter.JumpTarget jt, MemoryPtr condition ) {
		assert( jt < ir.currentFrame.sourceBytecode.length );

		if ( condition.readPrimitive!bool )
			ir.currentFrame.instructionPointer = cast( size_t ) jt;
	}

	void op_jmpFalse( Interpreter ir, Interpreter.JumpTarget jt, MemoryPtr condition ) {
		assert( jt < ir.currentFrame.sourceBytecode.length );

		if ( !condition.readPrimitive!bool )
			ir.currentFrame.instructionPointer = cast( size_t ) jt;
	}

	// MEMORY OPERATIONS
	void op_mov( Interpreter ir, MemoryPtr op1, MemoryPtr op2, size_t bytes ) {
		op1.write( op2, bytes );

		debug ( instructions )
			writefln( "\t\t  %#x => %#x\t%s", op2.val, op1.val, op1.read( bytes ) );
	}

	void op_movConst( Interpreter ir, MemoryPtr op1, size_t data, size_t bytes ) {
		version ( BigEndian ) static assert( 0 );
		op1.write( &data, bytes );

		debug ( instructions )
			writefln( "\t\t  => %#x\t%s", op1.val, cast( const( ubyte )[ ] )( cast( void* )&data )[ 0 .. bytes ] );
	}
