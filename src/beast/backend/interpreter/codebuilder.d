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
		alias InstructionPtr = size_t;

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
			assert( !currentFunction_ );

			currentFunction_ = func;

			pushScope( );
			body_( this );

			// Function MUST have a return instruction (for user functions, they're added automatically when return type is void)
			addInstruction( I.noReturnError, func.iopFuncPtr );
			popScope( false );
		}

	public:
		override void build_memoryAccess( MemoryPtr pointer ) {
			MemoryBlock block = pointer.block;
			operandResult_ = block.isLocal ? block.relatedDataEntity.asLocalVariable_interpreterBpOffset.iopBpOffset : pointer.iopPtr;
		}

		override void build_memoryWrite( MemoryPtr target, DataEntity data ) {
			MemoryBlock block = target.block;

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

				auto argVar = new DataEntity_TmpLocalVariable( param.dataType, false );
				build_localVariableDefinition( argVar );

				argVars[ i ] = argVar;
			}

			foreach ( i, ExpandedFunctionParameter param; function_.parameters ) {
				if ( param.isConstValue )
					continue;

				pushScope( );
				build_copyCtor( argVars[ i ], arguments[ i ] );
				popScope( );
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

		mixin Build_PrimitiveOperationImpl!( "interpreter", "operandResult_" );

	public:
		override void build_scope( StmtFunction body_ ) {
			pushScope( );
			body_( this );
			popScope( );
		}

		override void build_if( ExprFunction condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			pushScope( );

			auto _s = scoped!LocalDataScope( );
			auto _sgd = _s.scopeGuard; // Build the condition

			InstructionPtr condJmpInstr;
			{
				condition( this );
				condJmpInstr = addInstruction( I.jmpFalse, iopPlaceholder, operandResult_ );
			}

			// Build then branch
			InstructionPtr thenJmpInstr;
			{
				pushScope( );
				thenBranch( this );
				popScope( );

				if ( elseBranch )
					thenJmpInstr = addInstruction( I.jmp, iopPlaceholder );
			}

			setInstructionOperand( condJmpInstr, 0, jumpTarget );

			// Build else branch
			if ( elseBranch ) {
				pushScope( );
				elseBranch( this );
				popScope( );
				setInstructionOperand( thenJmpInstr, 0, jumpTarget );
			}

			popScope( );
			_s.finish( );
		}

		override void build_loop( StmtFunction body_ ) {
			auto jt = jumpTarget( );
			pushScope( ScopeFlags.loop );
			body_( this );
			popScope( );
			addInstruction( I.jmp, jt );
		}

		override void build_break( size_t scopeIndex ) {
			foreach_reverse ( ref s; scopeStack_[ scopeIndex .. $ ] )
				generateScopeExit( s );

			additionalScopeData_[ scopeIndex ].breakJumps ~= addInstruction( I.jmp, iopPlaceholder );
		}

		override void build_return( DataEntity returnValue ) {
			assert( currentFunction_ );

			if ( returnValue )
				build_copyCtor( new DataEntity_Result( currentFunction_, returnValue.dataType ), returnValue );

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
		pragma( inline ) InstructionPtr addInstruction( I i, InstructionOperand op1 = InstructionOperand( ), InstructionOperand op2 = InstructionOperand( ), InstructionOperand op3 = InstructionOperand( ) ) {
			result_ ~= Instruction( i, op1, op2, op3 );
			return result_.data.length - 1;
		}

		/// Updates instruction operand via it's ID (index)
		pragma( inline ) void setInstructionOperand( InstructionPtr instruction, size_t operandId, InstructionOperand set ) {
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
		override void pushScope( ScopeFlags flags = ScopeFlags.none ) {
			super.pushScope( flags );
			additionalScopeData_ ~= AdditionalScopeData( currentBPOffset_ );
		}

		override void popScope( bool generateDestructors = true ) {
			// Result might be f-ked around because of destructors
			auto result = operandResult_;

			super.popScope( generateDestructors );

			// "Link" break jumps that jump after scope exit
			if ( auto jmps = additionalScopeData_[ $ - 1 ].breakJumps ) {
				auto jt = jumpTarget( );
				foreach ( jmp; jmps )
					setInstructionOperand( jmp, 0, jt );
			}

			currentBPOffset_ = additionalScopeData_[ $ - 1 ].bpOffset;
			additionalScopeData_.length--;

			operandResult_ = result;
		}

	protected:
		override void generateScopeExit( ref Scope scope_ ) {
			super.generateScopeExit( scope_ );
			addInstruction( I.popScope, additionalScopeData_[ scope_.index ].bpOffset.iopLiteral );
		}

	package:
		Appender!( Instruction[ ] ) result_;
		InstructionOperand operandResult_;
		size_t currentBPOffset_;

	private:
		Symbol_RuntimeFunction currentFunction_;
		AdditionalScopeData[ ] additionalScopeData_ = [ AdditionalScopeData( ) ];

	private:
		struct AdditionalScopeData {
			size_t bpOffset;

			/// List of jmp instruction pointers generated by break statements
			/// Those instructions have placeholder as a target as the jump target was
			/// unknown when the jmp instruction was created
			/// breakJumps are "linked" in the popScope function
			InstructionPtr[ ] breakJumps;
		}

}
