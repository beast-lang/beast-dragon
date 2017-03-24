module beast.backend.interpreter.op.control;

import beast.backend.interpreter.op.toolkit;

//debug = instructions;

debug ( instructions ) {
	import std.stdio : writefln;
}

pragma( inline ):

	void op_noOp( Interpreter ir ) {
		// Do nothing
	}

	void op_noReturnError( Interpreter ir, Symbol_RuntimeFunction func ) {
		berror( E.noReturnExit, "Function %s did not exit via return statement".format( func.identificationString ) );
	}

	void op_printError( Interpreter ir ) {
		berror( E.functionNotCtime, "Cannot print to stdout at compile time" );
	}

	void op_assert_( Interpreter ir, MemoryPtr condition ) {
		benforce( condition.readPrimitive!bool, E.ctAssertFail, "An assert has failed during compile-time execution" );
	}

	// ALLOCATION/DEALLOCATION
	void op_allocLocal( Interpreter ir, size_t bpOffset, size_t bytes ) {
		const size_t stackOffset = ir.currentFrame.basePointer + bpOffset;

		assert( stackOffset == ir.stack.length, "AllocLocal offset mismatch %s expected %s got".format( ir.stack.length, stackOffset ) );
		ir.stack ~= memoryManager.alloc( bytes );
	}

	void op_skipAlloc( Interpreter ir, size_t bpOffset ) {
		const size_t stackOffset = ir.currentFrame.basePointer + bpOffset;

		assert( stackOffset == ir.stack.length, "AllocLocal offset mismatch %s expected %s got".format( ir.stack.length, stackOffset ) );
		ir.stack ~= MemoryPtr( );
	}

	void op_popScope( Interpreter ir, size_t targetBpOffset ) {
		const size_t targetStackSize = ir.currentFrame.basePointer + targetBpOffset;

		assert( targetStackSize < ir.stack.length, "popScope out of bounds (%s - %s)".format( ir.stack.length, targetStackSize ) );

		foreach ( ptr; ir.stack[ targetStackSize .. $ ] ) {
			if ( !ptr.isNull )
				memoryManager.free( ptr );
		}

		ir.stack.length = targetStackSize;
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
