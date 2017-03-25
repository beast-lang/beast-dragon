module beast.backend.interpreter.codebuilder;

import beast.backend.toolkit;
import std.array : Appender, appender;
import beast.backend.interpreter.instruction;
import beast.backend.interpreter.codeblock;
import beast.code.data.var.result;
import beast.code.data.scope_.local;

/// "CodeBuilder" that builds code for the internal interpret
final class CodeBuilder_Interpreter : CodeBuilder {
	alias I = Instruction.I;

	public:
		final string identificationString( ) {
			return "interpreter";
		}

		final InterpreterCodeBlock result( ) {
			return new InterpreterCodeBlock( result_.data );
		}

	public:
		override void build_localVariableDefinition( DataEntity_LocalVariable var ) {
			var.interpreterBpOffset = currentBPOffset_;
			addToScope( var );

			addInstruction( I.allocLocal, currentBPOffset_.iopLiteral, var.dataType.instanceSize.iopLiteral );
			operandResult_ = currentBPOffset_.iopBpOffset;

			currentBPOffset_++;
		}

		override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			assert( currentBPOffset_ == 0 );

			auto prevFunc = currentFunction;
			currentFunction = func;

			pushScope( );
			body_( this );

			// Function MUST have a return instruction (for user functions, they're added automatically when return type is void)
			addInstruction( I.noReturnError, func.iopFuncPtr );
			popScope( false );

			currentFunction = prevFunc;
		}

	public:
		override void build_memoryAccess( MemoryPtr pointer ) {
			MemoryBlock block = pointer.block;
			operandResult_ = block.isLocal ? block.localVariable.interpreterBpOffset.iopBpOffset : pointer.iopPtr;
		}

		override void build_memoryWrite( MemoryPtr target, DataEntity data ) {
			data.buildCode( this );
			InstructionOperand assignedValue = operandResult_;

			build_memoryAccess( target );
			addInstruction( I.mov, operandResult_, assignedValue, data.dataType.instanceSize.iopLiteral );
		}

		override void build_functionCall( Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			/*
				Call convention:
				RETURN ARG3 ARG2 ARG1 CONTEXT
				context is always present
				constnant value args also get their BPoffset (it is unused though, even unallocated)
			*/

			InstructionOperand operandResult;

			if ( function_.returnType !is coreLibrary.type.Void ) {
				auto returnVar = new DataEntity_TmpLocalVariable( function_.returnType, false );
				build_localVariableDefinition( returnVar );
				operandResult = operandResult_;
			}

			pushScope( );

			DataEntity_TmpLocalVariable[ ] argVars;
			argVars.length = function_.parameters.length;

			// Because of call convention (where the argument order is RET ARG3 ARG2 ARG1 CTX), we need to initialize this rather strangely
			foreach_reverse ( i, ExpandedFunctionParameter param; function_.parameters ) {
				if ( param.isConstValue ) {
					currentBPOffset_++;
					continue;
				}

				auto argVar = new DataEntity_TmpLocalVariable( function_.returnType, false );
				build_localVariableDefinition( argVar );

				argVars[ i ] = argVar;
			}

			foreach ( i, ExpandedFunctionParameter param; function_.parameters ) {
				if ( param.isConstValue )
					continue;

				build_copyCtor( argVars[ i ], arguments[ i ] );
			}

			if ( function_.declarationType == Symbol.DeclType.memberFunction ) {
				parentInstance.buildCode( this );
			}
			else {
				addInstruction( I.skipAlloc, currentBPOffset_.iopLiteral );
				currentBPOffset_++;
			}

			addInstruction( I.call, function_.iopFuncPtr );

			popScope( );
			operandResult_ = operandResult;
		}

		override void build_primitiveOperation( Symbol_Type returnType, BackendPrimitiveOperation op, DataEntity parentInstance, DataEntity[ ] arguments ) {
			static import beast.backend.interpreter.primitiveop;

			if ( returnType !is coreLibrary.type.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( returnType, false );
				build_localVariableDefinition( resultVar );
			}

			auto _s = scoped!LocalDataScope( );
			auto _sgd = _s.scopeGuard;
			pushScope( );

			mixin( ( ) { //
				import std.array : appender;

				auto result = appender!string;
				result ~= "final switch( op ) {\n";

				foreach ( opStr; __traits( derivedMembers, BackendPrimitiveOperation ) ) {
					result ~= "case BackendPrimitiveOperation.%s:\n".format( opStr );

					static if ( __traits( hasMember, beast.backend.interpreter.primitiveop, "primitiveOp_%s".format( opStr ) ) )
						result ~= "beast.backend.interpreter.primitiveop.primitiveOp_%s( this, parentInstance, arguments );\nbreak;\n".format( opStr );
					else
						result ~= "assert( 0, \"primitiveOp %s is not implemented for codebuilder.interpreter\" );\n".format( opStr );
				}

				result ~= "}\n";
				return result.data;
			}( ) );

			popScope( );
			_s.finish( );
		}

	public:
		override void build_return( DataEntity returnValue ) {
			assert( currentFunction );

			if ( returnValue )
				build_copyCtor( new DataEntity_Result( currentFunction, returnValue.dataType ), returnValue );

			generateScopesExit( );
			addInstruction( I.ret );
		}

	public:
		void debugPrintResult( string desc ) {
			if ( !result_.data.length )
				return;

			import std.stdio : writefln;
			import beast.core.error.error : stderrMutex;

			synchronized ( stderrMutex ) {
				writefln( "\n== BEGIN CODE %s\n", desc );

				foreach ( i, instr; result_.data )
					writefln( "@%3s   %s", i, instr.identificationString );

				writefln( "\n== END\n" );
			}
		}

	package:
		/// Adds instruction, returns it's ID (index)
		pragma( inline ) size_t addInstruction( I i, InstructionOperand op1 = InstructionOperand( ), InstructionOperand op2 = InstructionOperand( ), InstructionOperand op3 = InstructionOperand( ) ) {
			result_ ~= Instruction( i, op1, op2, op3 );
			return result_.data.length - 1;
		}

		/// Updates instruction operand via it's ID (index)
		pragma( inline ) void setInstructionOperand( size_t instruction, size_t operandId, InstructionOperand set ) {
			assert( result_.data[ instruction ].op[ operandId ].type == InstructionOperand.Type.placeholder, "You can only update placeholder operands" );
			result_.data[ instruction ].op[ operandId ] = set;
		}

		/// Returns operand representing a next instruction jump target
		pragma( inline ) InstructionOperand jumpTarget( ) {
			InstructionOperand result = InstructionOperand( InstructionOperand.Type.jumpTarget );
			result.jumpTarget = result_.data.length;
			return result;
		}

	public:
		override void pushScope( ) {
			bpOffsetStack_ ~= currentBPOffset_;
			super.pushScope( );
		}

		override void popScope( bool generateDestructors = true ) {
			// Result might be f-ked around because of destructors
			auto result = operandResult_;

			super.popScope( generateDestructors );

			if ( currentBPOffset_ != bpOffsetStack_[ $ - 1 ] )
				addInstruction( I.popScope, bpOffsetStack_[ $ - 1 ].iopLiteral );

			currentBPOffset_ = bpOffsetStack_[ $ - 1 ];
			bpOffsetStack_.length--;

			operandResult_ = result;
		}

	package:
		Appender!( Instruction[ ] ) result_;
		InstructionOperand operandResult_;
		size_t[ ] bpOffsetStack_;
		size_t currentBPOffset_;

	private:
		Symbol_RuntimeFunction currentFunction;

}
