module beast.backend.interpreter.codebuilder;

import beast.backend.toolkit;
import std.array : Appender, appender;
import beast.backend.interpreter.instruction;
import beast.backend.interpreter.codeblock;

/// "CodeBuilder" that builds code for the internal interpret
final class CodeBuilder_Interpreter : CodeBuilder {
	alias I = Instruction.I;

	public:
		final string identificationString( ) {
			return "interpret";
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

			pushScope( );
			body_( this );
			popScope( );
		}

	public:
		override void build_memoryAccess( MemoryPtr pointer ) {
			MemoryBlock block = pointer.block;
			operandResult_ = block.isLocal ? block.localVariable.interpreterBpOffset.iopBpOffset : pointer.iopPtr;
		}

		override void build_memoryWrite( DataScope scope_, MemoryPtr target, DataEntity data ) {
			data.buildCode( this, scope_ );
			InstructionOperand assignedValue = operandResult_;

			build_memoryAccess( target );
			addInstruction( I.mov, operandResult_, assignedValue, data.dataType.instanceSize.iopLiteral );
		}

		override void build_functionCall( DataScope scope_, Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			if ( function_.returnType !is coreLibrary.type.Void ) {
				auto returnVar = new DataEntity_TmpLocalVariable( function_.returnType, scope_, false );
				build_localVariableDefinition( returnVar );
				operandResult_ = returnVar.interpreterBpOffset.iopBpOffset;
			}
			else
				debug operandResult_ = InstructionOperand( );

			pushScope( );

			foreach ( i, ExpandedFunctionParameter param; function_.parameters ) {
				if ( param.isConstValue )
					continue;

				auto argVar = new DataEntity_TmpLocalVariable( function_.returnType, scope_, false );
				build_localVariableDefinition( argVar );
				build_copyCtor( argVar, arguments[ i ], scope_ );
			}

			if ( function_.declarationType == Symbol.DeclType.memberFunction ) {
				parentInstance.buildCode( this, scope_ );
				
			}

			addInstruction( I.call, function_.iopFuncPtr );

			popScope( );
		}

	protected:
		pragma( inline ) void addInstruction( I i, InstructionOperand op1 = InstructionOperand( ), InstructionOperand op2 = InstructionOperand( ), InstructionOperand op3 = InstructionOperand( ) ) {
			result_ ~= Instruction( i, op1, op2, op3 );
		}

		pragma( inline ) void setInstructionOperand( size_t instruction, size_t operandId, InstructionOperand set ) {
			result_.data[ instruction ].op[ operandId ] = set;
		}

	protected:
		override void pushScope( ) {
			bpOffsetStack_ ~= currentBPOffset_;
			super.pushScope( );
		}

		override void popScope( ) {
			super.popScope( );
			currentBPOffset_ = bpOffsetStack_[ $ - 1 ];
			bpOffsetStack_.length--;
		}

	private:
		Appender!( Instruction[ ] ) result_;
		InstructionOperand operandResult_;
		size_t[ ] bpOffsetStack_;
		size_t currentBPOffset_;

}
