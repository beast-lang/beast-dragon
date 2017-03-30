module beast.backend.interpreter.op.control;

import beast.backend.interpreter.op.toolkit;

//debug = interpreter;

debug( interpreter ) {
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

	void op_popScope( Interpreter ir, size_t targetBpOffset ) {
		const size_t targetStackSize = ir.currentFrame.basePointer + targetBpOffset;

		assert( targetStackSize <= ir.stack.length, " popScope out of bounds(  % s -  % s ) ".format( ir.stack.length, targetStackSize ) );

		foreach ( i; targetStackSize .. ir.stack.length ) {
			auto ptr = ir.stack[ i ];

			if ( !ptr.isNull ) {
				debug( interpreter )
					writefln( "free BP+%s (%#x)", i, ptr.val );

				memoryManager.free( ptr );

			}
			else
				debug( interpreter )
					writefln( "free BP+%s (null)", i );
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

			context.currentRecursionLevel++;
			benforce( context.currentRecursionLevel <= project.configuration.maxRecursion, E.ctStackOverflow, "Recursion of compile time function execution exceeded the limit of %s".format( project.configuration.maxRecursion ) );
		}
	}

	void op_ret( Interpreter ir ) {
		with ( ir ) {
			assert( callStack.length );

			op_popScope( ir, 0 );

			currentFrame = callStack[ $ - 1 ];
			callStack.length--;
			context.currentRecursionLevel--;
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
