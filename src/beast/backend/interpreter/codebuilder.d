module beast.backend.interpreter.codebuilder;

import beast.backend.toolkit;
import std.array : Appender, appender;
import beast.backend.interpreter.instruction;
import beast.backend.interpreter.codeblock;
import beast.code.data.var.result;
import beast.code.data.scope_.local;
import beast.backend.common.codebuilder;
import std.algorithm : count;

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
			return new InterpreterCodeBlock( resultCode_.data );
		}

	public:
		override void build_localVariableDefinition( DataEntity_LocalVariable var ) {
			var.allocate( false );
			var.memoryBlock.bpOffset = currentBPOffset_;

			addToScope( var );

			addInstruction( I.allocLocal, currentBPOffset_.iopLiteral, var.dataType.instanceSize.iopLiteral );
			result_ = currentBPOffset_.iopBpOffset;

			currentBPOffset_++;
		}

		override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			assert( currentBPOffset_ == 0 );
			assert( currentCTOffset_ == 0 );
			assert( !currentFunction_ );

			currentFunction_ = func;

			pushScope( ScopeFlags.sessionRoot );
			body_( this );

			// Function MUST have a return instruction (for user functions, they're added automatically when return type is void)
			addInstruction( I.noReturnError, func.iopFuncPtr );
			popScope( false );

			trashCtimeChanges( );
		}

	public:
		override void build_memoryAccess( MemoryPtr pointer ) {
			mirrorCtimeChanges( );
			build_memoryAccess_noMirrorCtimeChanges( pointer );
		}

		override void build_offset( ExprFunction expr, size_t offset ) {
			expr( this );
			build_offset( offset );
		}

		final void build_offset( size_t offset ) {
			if ( offset == 0 )
				return;

			final switch ( result_.type ) {

			case InstructionOperand.Type.directData:
			case InstructionOperand.Type.functionPtr:
			case InstructionOperand.Type.jumpTarget:
			case InstructionOperand.Type.placeholder:
			case InstructionOperand.Type.unused:
				assert( 0, "Cannot offset operand %s".format( result_.identificationString ) );

			case InstructionOperand.Type.heapRef:
				result_.heapLocation.val += offset;
				break;

			case InstructionOperand.Type.stackRef:
			case InstructionOperand.Type.ctStackRef:
			case InstructionOperand.Type.refHeapRef:
			case InstructionOperand.Type.refStackRef: {
			case InstructionOperand.Type.refCtStackRef:
					auto varOperand = currentBPOffset_.iopBpOffset;
					auto ptrSize = hardwareEnvironment.pointerSize;

					addInstruction( I.allocLocal, currentBPOffset_.iopLiteral, ptrSize.iopLiteral );
					addInstruction( I.stAddr, varOperand, result_ );
					addInstruction( Instruction.numericI( ptrSize, Instruction.NumI.addConst ), varOperand, varOperand, offset.iopLiteral );

					result_ = currentBPOffset_.iopRefBpOffset;

					currentBPOffset_++;
				}
				break;

			}
		}

		override void build_functionCall( Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			/*
				Call convention:
				RETURN ARG3 ARG2 ARG1 CONTEXT
				context is always present
				constnant value args are ignored
			*/

			// Because of stuff, parameters are passed by reference -> we execute their expressions, and then add pointer to those expression results just before calling the function

			assert( arguments.length == function_.parameters.count!( x => !x.isConstValue ) );

			InstructionOperand resultOperand;
			if ( function_.returnType !is coreType.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( function_.returnType );
				build_localVariableDefinition( resultVar );
				resultOperand = result_;
			}

			InstructionOperand ctxOperand;
			if ( function_.declarationType == Symbol.DeclType.memberFunction ) {
				assert( parentInstance );
				parentInstance.buildCode( this );
				ctxOperand = result_;
			}

			InstructionOperand[ ] argVars;
			foreach ( ExpandedFunctionParameter param; function_.parameters.filter!( x => !x.isConstValue ) ) {
				auto argVar = new DataEntity_TmpLocalVariable( param.dataType );
				build_localVariableDefinition( argVar );
				build_copyCtor( argVar, arguments[ param.runtimeIndex ] );

				assert( argVars.length == param.runtimeIndex );
				argVars ~= argVar.memoryBlock.bpOffset.iopBpOffset;
			}

			if ( resultOperand.isUsed )
				addPointerVariableOnStack( resultOperand );

			foreach_reverse ( argVar; argVars )
				addPointerVariableOnStack( argVar );

			if ( ctxOperand.isUsed )
				addPointerVariableOnStack( ctxOperand );
			else {
				addInstruction( I.skipAlloc, currentBPOffset_.iopLiteral );
				currentBPOffset_++;
			}

			addInstruction( I.call, function_.iopFuncPtr );

			result_ = resultOperand;
		}

		override void build_contextPtrAccess( ) {
			result_ = ( -1 ).iopRefBpOffset;
		}

		override void build_parameterAccess( ExpandedFunctionParameter param ) {
			result_ = ( -param.runtimeIndex - 2 ).iopRefBpOffset;
		}

		override void build_functionResultAccess( Symbol_RuntimeFunction func ) {
			result_ = ( -func.parameters.count!( x => x.constValue.isNull ) - 2 ).iopRefBpOffset;
		}

		override void build_dereference( ExprFunction arg ) {
			arg( this );

			switch ( result_.type ) {

			case InstructionOperand.Type.heapRef: // If the operands are not already references, we simply make them into references
				result_.type = InstructionOperand.Type.refHeapRef;
				break;

			case InstructionOperand.Type.stackRef:
				result_.type = InstructionOperand.Type.refStackRef;
				break;

			case InstructionOperand.Type.ctStackRef:
				result_.type = InstructionOperand.Type.refCtStackRef;
				break;

			case InstructionOperand.Type.refHeapRef: // If the operands are references, we have to dereference them first (store the address into local variable)
			case InstructionOperand.Type.refStackRef:
			case InstructionOperand.Type.refCtStackRef:
				addInstruction( I.allocLocal, currentBPOffset_.iopLiteral, hardwareEnvironment.pointerSize.iopLiteral );
				addInstruction( I.mov, currentBPOffset_.iopBpOffset, result_, hardwareEnvironment.pointerSize.iopLiteral );

				result_ = currentBPOffset_.iopRefBpOffset;

				currentBPOffset_++;
				break;

			default:
				assert( 0, "Invalid operand type" );

			}
		}

		mixin Build_PrimitiveOperationImpl!( "interpreter", "result_" );

	public:
		override void build_scope( StmtFunction body_ ) {
			pushScope( );
			body_( this );
			popScope( );
		}

		override void build_if( ExprFunction condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			pushScope( );

			InstructionPtr condJmpInstr;
			{
				condition( this );
				condJmpInstr = addInstruction( I.jmpFalse, iopPlaceholder, result_ );
			}

			// Build then branch
			InstructionPtr thenJmpInstr;
			{
				// Branch bodies are in custom sessions to prevent changing @ctime variables outside the runtime bodies
				with ( memoryManager.session( SessionPolicy.inheritCtChangesWatcher ) ) {
					pushScope( ScopeFlags.sessionRoot );
					thenBranch( this );
					popScope( );

					if ( elseBranch )
						thenJmpInstr = addInstruction( I.jmp, iopPlaceholder );
				}
			}

			setInstructionOperand( condJmpInstr, 0, jumpTarget );

			// Build else branch
			if ( elseBranch ) {
				// Branch bodies are in custom sessions to prevent changing @ctime variables outside the runtime bodies
				with ( memoryManager.session( SessionPolicy.inheritCtChangesWatcher ) ) {
					pushScope( ScopeFlags.sessionRoot );
					elseBranch( this );
					popScope( );
					setInstructionOperand( thenJmpInstr, 0, jumpTarget );
				}
			}

			popScope( );
		}

		override void build_loop( StmtFunction body_ ) {
			pushScope( ScopeFlags.loop );
			auto jt = jumpTarget( );

			// Branch bodies are in custom sessions to prevent changing @ctime variables outside the runtime bodies
			with ( memoryManager.session( SessionPolicy.inheritCtChangesWatcher ) ) {
				pushScope( ScopeFlags.sessionRoot );
				body_( this );
				popScope( );
			}

			addInstruction( I.jmp, jt );
			popScope( );
		}

		override void build_break( size_t scopeIndex ) {
			foreach_reverse ( ref s; scopeStack_[ scopeIndex .. $ ] )
				generateScopeExit( s );

			additionalScopeData_[ scopeIndex ].breakJumps ~= addInstruction( I.jmp, iopPlaceholder );
		}

		override void build_return( DataEntity returnValue ) {
			assert( currentFunction_ );

			if ( returnValue )
				build_copyCtor( new DataEntity_Result( currentFunction_, false, returnValue.dataType ), returnValue );

			generateScopesExit( );
			addInstruction( I.ret );
		}

	public:
		void debugPrintResult( string desc ) {
			if ( !resultCode_.data.length )
				return;

			import std.stdio : writefln, stdout;
			import beast.core.error.error : stderrMutex;

			// uncommenting this causes freezes - dunno why
			//synchronized ( stderrMutex ) {
			writefln( "\n== BEGIN CODE %s\n", desc );

			foreach ( i, instr; resultCode_.data )
				writefln( "@%3s   %s", i, instr.identificationString );

			writefln( "\n== END\n" );
			//stdout.flush();
			//}
		}

	protected:
		override void mirrorBlockAllocation( MemoryBlock block ) {
			debug assert( block.session == context.session );

			assert( !block.bpOffset );
			block.bpOffset = currentCTOffset_;
			addInstruction( I.allocCt, currentCTOffset_.iopLiteral, block.size.iopLiteral );
			currentCTOffset_++;
		}

		override void mirrorBlockDataChange( MemoryBlock block ) {
			debug assert( block.session == context.session );

			MemoryBlock data = block.duplicate( MemoryBlock.Flag.ctime | MemoryBlock.Flag.dynamicallyAllocated | MemoryBlock.Flag.doNotMirrorChanges );
			data.markDoNotGCAtSessionEnd( );

			debug ( interpreter ) {
				import std.stdio : writefln;

				writefln( "Mirror %s %s (CT+%s) (pointers %s) (%s) dup %s", block.startPtr, block.data[ 0 .. block.size ], block.bpOffset, memoryManager.pointersInSessionBlock( block ), block.identificationString, data.startPtr );
			}

			auto blockOperand = block.bpOffset.iopCtOffset;
			auto ptrSize = hardwareEnvironment.pointerSize.iopLiteral;

			// Update the local @ctime block
			addInstruction( I.mov, blockOperand, data.startPtr.iopPtr, block.size.iopLiteral );

			// Update pointers
			foreach ( ptr; memoryManager.pointersInSessionBlock( block ) ) {
				assert( ptr.val >= block.startPtr.val && ptr.val <= block.endPtr.val - hardwareEnvironment.pointerSize );

				build_memoryAccess_noMirrorCtimeChanges( ptr );
				auto target = result_;

				auto ptrPtr = ptr.readMemoryPtr;

				if ( ptrPtr.isNull ) {
					addInstruction( I.movConst, target, 0.iopLiteral, ptrSize );
				}
				else {
					build_memoryAccess_noMirrorCtimeChanges( ptrPtr );
					addInstruction( I.stAddr, target, result_, ptrSize );
				}
			}
		}

		override void mirrorBlockDeallocation( MemoryBlock block ) {
			assert( block.isCtime );

			addInstruction( I.freeCt, block.bpOffset.iopLiteral );
		}

	protected:
		void addPointerVariableOnStack( InstructionOperand pointerTarget ) {
			assert( pointerTarget.isUsed );

			addInstruction( I.allocLocal, currentBPOffset_.iopLiteral, hardwareEnvironment.pointerSize.iopLiteral );
			addInstruction( I.markPtr, currentBPOffset_.iopBpOffset );
			addInstruction( I.stAddr, currentBPOffset_.iopBpOffset, pointerTarget );
			currentBPOffset_++;
		}

	package:
		/// Adds instruction, returns it's ID (index)
		pragma( inline ) InstructionPtr addInstruction( I i, InstructionOperand op1 = InstructionOperand( ), InstructionOperand op2 = InstructionOperand( ), InstructionOperand op3 = InstructionOperand( ) ) {
			resultCode_ ~= Instruction( i, op1, op2, op3 );
			return resultCode_.data.length - 1;
		}

		/// Updates instruction operand via it's ID (index)
		pragma( inline ) void setInstructionOperand( InstructionPtr instruction, size_t operandId, InstructionOperand set ) {
			assert( resultCode_.data[ instruction ].op[ operandId ].type == InstructionOperand.Type.placeholder, "You can only update placeholder operands" );
			resultCode_.data[ instruction ].op[ operandId ] = set;
		}

		/// Returns operand representing a next instruction jump target
		pragma( inline ) InstructionOperand jumpTarget( ) {
			InstructionOperand result = InstructionOperand( InstructionOperand.Type.jumpTarget );
			result.jumpTarget = resultCode_.data.length;
			return result;
		}

	public:
		override void pushScope( ScopeFlags flags = ScopeFlags.none ) {
			super.pushScope( flags );
			additionalScopeData_ ~= AdditionalScopeData( currentBPOffset_ );
		}

		override void popScope( bool generateDestructors = true ) {
			// Result might be f-ked around because of destructors
			auto result = result_;

			super.popScope( generateDestructors );

			// "Link" break jumps that jump after scope exit
			if ( auto jmps = additionalScopeData_[ $ - 1 ].breakJumps ) {
				auto jt = jumpTarget( );
				foreach ( jmp; jmps )
					setInstructionOperand( jmp, 0, jt );
			}

			currentBPOffset_ = additionalScopeData_[ $ - 1 ].bpOffset;
			additionalScopeData_.length--;

			result_ = result;
		}

	protected:
		override void generateScopeExit( ref Scope scope_ ) {
			super.generateScopeExit( scope_ );

			size_t targetBPOffset = additionalScopeData_[ scope_.index ].bpOffset;

			if ( targetBPOffset < currentBPOffset_ )
				addInstruction( I.popScope, targetBPOffset.iopLiteral );
		}

	protected:
		final void build_memoryAccess_noMirrorCtimeChanges( MemoryPtr pointer ) {
			MemoryBlock block = pointer.block;

			// Prevent the memory block being GC collected at session end - it might be used in function execution
			// This is to prevent static variables from being collected
			block.markDoNotGCAtSessionEnd( );

			result_ = memoryBlockOperand( block );
			if ( block.startPtr != pointer )
				build_offset( pointer.val - block.startPtr.val );
		}

		final InstructionOperand memoryBlockOperand( MemoryBlock block ) {
			if ( !block.isRuntime && block.session == context.session )
				return block.bpOffset.iopCtOffset;
			else if ( block.isLocal )
				return block.bpOffset.iopBpOffset;
			else
				return block.startPtr.iopPtr;
		}

	package:
		Appender!( Instruction[ ] ) resultCode_;
		InstructionOperand result_;
		size_t currentBPOffset_, currentCTOffset_;

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
