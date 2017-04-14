module beast.backend.common.codebuilder;

import beast.backend.toolkit;
import beast.util.identifiable;
import beast.backend.ctime.codebuilder : CodeBuilder_Ctime;

/// Root class for building code with any backend
abstract class CodeBuilder : Identifiable {

	public:
		/// When called, StmtFunction should build given part of the statement using provided codebuilder
		alias StmtFunction = void delegate( CodeBuilder cb );

		/// When called, StmtFunction should build expression using provided codebuilder		
		alias ExprFunction = void delegate( CodeBuilder cb );

	public:
		bool isCtime( ) {
			return false;
		}

	public: // Declaration related build commands
		void build_localVariableDefinition( DataEntity_LocalVariable var ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_typeDefinition( Symbol_Type type ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

	public: // Expression related build commands
		/// Builds access to a memory (passed by a pointer)
		/// The memory doesn't have to be static! You have to check associated memory block flags (it can be local ctime variable or so)
		void build_memoryAccess( MemoryPtr pointer ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		/// Builds access to a memory described by expr but offsetted with offset
		void build_offset( ExprFunction expr, size_t offset ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_functionCall( Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_primitiveOperation( BackendPrimitiveOperation op, Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		/// Builds access to context ptr
		void build_contextPtr( ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		/// Utility function calling original build_primitiveOperation (argT => arg1.dataType)
		pragma( inline ) final void build_primitiveOperation( BackendPrimitiveOperation op, DataEntity arg1 ) {
			build_primitiveOperation( op, arg1.dataType, &arg1.buildCode );
		}

		/// Utility function calling original build_primitiveOperation (argT => arg1.dataType)
		pragma( inline ) final void build_primitiveOperation( BackendPrimitiveOperation op, DataEntity arg1, DataEntity arg2 ) {
			build_primitiveOperation( op, arg1.dataType, &arg1.buildCode, &arg2.buildCode );
		}

		/// Utility function calling original build_primitiveOperation (argT => arg1.dataType)
		pragma( inline ) final void build_primitiveOperation( BackendPrimitiveOperation op, DataEntity arg1, DataEntity arg2, DataEntity arg3 ) {
			build_primitiveOperation( op, arg1.dataType, &arg1.buildCode, &arg2.buildCode, &arg3.buildCode );
		}

		/// Utility function calling original build_primitiveOperation
		pragma( inline ) final void build_primitiveOperation( BackendPrimitiveOperation op, Symbol_Type argT, DataEntity arg1, DataEntity arg2, DataEntity arg3 ) {
			build_primitiveOperation( op, argT, &arg1.buildCode, &arg2.buildCode, &arg3.buildCode );
		}

	public: // Statement related build commands
		void build_scope( StmtFunction body_ ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		/// Builds the "if" construction
		/// Condition has to be of type bool
		/// elseBranch can be null
		void build_if( ExprFunction condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		/// Utility function for if
		final void build_if( DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			build_if( &condition.buildCode, thenBranch, elseBranch );
		}

		/// Builds the "loop" construction - infinite loop (has to be stopped using break)
		void build_loop( StmtFunction body_ ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		/// Builds the "break" construction - exists the topmost breakable scope (breakable without a label)
		final void build_break( ) {
			foreach_reverse ( i, ref s; scopeStack_ ) {
				if ( s.flags & ScopeFlags.breakableWithoutLabel ) {
					assert( i != 0 );
					build_break( i );
					return;
				}
			}

			berror( E.nothingToBreakOrContinue, "There is nothing you can break from implicitly - decorate the desired scope with @label( \"xx\" ) and then use \"break xx;\"" );
		}

		/// Builds the "break" construction - exits all scopes up to given index (inclusive) (index is given by scopeStack_)
		void build_break( size_t scopeIndex ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_return( DataEntity returnValue ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

	public:
		final void build_copyCtor( DataEntity_LocalVariable var, DataEntity initValue ) {
			// We don't call var.tryResolveIdentifier because of Type variables
			// calling var.tryResolveIdentifier would result in calling #ctor of the represented type
			var.dataType.expectResolveIdentifier_direct( ID!"#ctor", var ).resolveCall( var.ast, true, initValue ).buildCode( this );
		}

		final void build_dtor( DataEntity_LocalVariable var ) {
			string id = var.identificationString;
			bool isCtime = var.isCtime;

			// We don't call var.tryResolveIdentifier because of Type variables
			// calling var.tryResolveIdentifier would result in calling #ctor of the represented type
			var.dataType.expectResolveIdentifier_direct( ID!"#dtor", var ).resolveCall( null, true ).buildCode( var.isCtime ? new CodeBuilder_Ctime : this );

			if ( var.isCtime ) {
				mirrorCtimeChanges( );
				mirrorBlockDeallocation( var.memoryBlock );
			}
		}

	protected:
		/// Mirrors @ctime changes into the runtime code
		final void mirrorCtimeChanges( ) {
			if ( this.isCtime )
				return;

			foreach ( block; *context.sessionData.newMemoryBlocks ) {
				// We ignore memory blocks that are runtime
				if ( block.isRuntime )
					continue;

				assert( block.flag( MemoryBlock.SharedFlag.allocated ) );

				// If the block has been both allocated and deallocated between two mirorrings, ignore it completely
				if ( block.flag( MemoryBlock.SharedFlag.freed ) )
					continue;

				mirrorBlockAllocation( block );
			}

			foreach ( block; context.sessionData.changedMemoryBlocks ) {
				// We ignore memory blocks that are runtime
				if ( block.isRuntime )
					continue;

				// If the block has been both allocated and deallocated between two mirorrings, ignore it completely
				if ( block.flag( MemoryBlock.SharedFlag.allocated | MemoryBlock.SharedFlag.freed ) )
					continue;

				assert( block.flag( MemoryBlock.SharedFlag.changed ) );

				if ( block.flag( MemoryBlock.SharedFlag.freed ) ) {
					// We don't mirror destruction of local variables - those are handled in scope exit destructors
					if ( !block.flag( MemoryBlock.Flag.local ) )
						mirrorBlockDeallocation( block );
				}
				else
					mirrorBlockDataChange( block );

				block.setFlags( MemoryBlock.SharedFlag.changed | MemoryBlock.SharedFlag.allocated, false );
			}

			context.sessionData.changedMemoryBlocks.clear( );
			context.sessionData.newMemoryBlocks.length = 0;
		}

		/// Trashes unmirrored ctime changes - used when there was an error during the compilation
		final void trashCtimeChanges( ) {
			context.sessionData.changedMemoryBlocks.clear( );
		}

		void mirrorBlockAllocation( MemoryBlock block ) {

		}

		void mirrorBlockDataChange( MemoryBlock block ) {

		}

		void mirrorBlockDeallocation( MemoryBlock block ) {

		}

	public:
		/// Creates a new scope (scopes are stored on a stack)
		/// CodeBuilder scopes are used for destructor generating
		void pushScope( ScopeFlags flags = ScopeFlags.none ) {
			scopeStack_ ~= Scope( scopeStack_.length, flags );
		}

		/// Destroys the last scope
		/// CodeBuilder scopes are used for destructor generating
		void popScope( bool generateDestructors = true ) {
			if ( generateDestructors )
				generateScopeExit( scopeStack_[ $ - 1 ] );

			// Free memory allocated by local variables
			foreach_reverse ( var; scopeStack_[ $ - 1 ].variables )
				memoryManager.free( var.memoryBlock );

			scopeStack_.length--;
			mirrorCtimeChanges( );
		}

		/// Generates destructors for all the scope
		final void generateScopesExit( ) {
			foreach_reverse ( ref s; scopeStack_ )
				generateScopeExit( s );
		}

		final void addToScope( DataEntity_LocalVariable var ) {
			scopeStack_[ $ - 1 ].variables ~= var;
		}

		final DataEntity_LocalVariable[ ] scopeItems( ) {
			return scopeStack_[ $ - 1 ].variables;
		}

	protected:
		void generateScopeExit( ref Scope scope_ ) {
			foreach_reverse ( var; scope_.variables )
				build_dtor( var );
		}

	protected:
		Scope[ ] scopeStack_ = [ Scope( 0 ) ];

	protected:
		struct Scope {
			/// Index of the scope in the scopeStack_
			size_t index;
			ScopeFlags flags;
			DataEntity_LocalVariable[ ] variables;
		}

		enum ScopeFlags {
			/// If the scope can be breaked/continued just using break; (without @label("xx") and break xx;)
			breakableWithoutLabel = 1,
			/// Whether it is possible to use continue statement on the scope
			continuable = breakableWithoutLabel << 1,

			none = 0,
			loop = breakableWithoutLabel | continuable,
		}

		mixin template Build_PrimitiveOperationImpl( string packageName, string resultVar ) {
			override void build_primitiveOperation( BackendPrimitiveOperation op, Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null ) {
				mixin( "static import beast.backend.%s.primitiveop;".format( packageName ) );

				mixin( ( ) { //
					import std.array : appender;
					import std.traits : Parameters;

					auto result = appender!string;
					result ~= "final switch( op ) {\n";

					foreach ( opStr; __traits( derivedMembers, BackendPrimitiveOperation ) ) {
						result ~= "case BackendPrimitiveOperation.%s:\n".format( opStr );

						static if ( __traits( hasMember, mixin( "beast.backend.%s.primitiveop".format( packageName ) ), "primitiveOp_%s".format( opStr ) ) ) {
							mixin( "alias func = beast.backend.%s.primitiveop.primitiveOp_%s;".format( packageName, opStr ) );
							alias params = Parameters!func;

							static if ( params.length == 1 )
								result ~= "{ beast.backend.%s.primitiveop.primitiveOp_%s( this ); break; }\n".format( packageName, opStr );
							else static if ( params.length == 2 )
								result ~= "{ assert( argT, \"argT is null %s %s\" ); beast.backend.%s.primitiveop.primitiveOp_%s( this, argT ); break; }\n".format( packageName, opStr, packageName, opStr );
							else static if ( params.length == 3 )
								result ~= "{ assert( argT, \"argT is null %s %s\" ); assert( arg1, \"arg1 is null %s %s\" ); arg1( this ); beast.backend.%s.primitiveop.primitiveOp_%s( this, argT, %s ); break; }\n".format( packageName, opStr, packageName, opStr, packageName, opStr, resultVar );
							else static if ( params.length == 4 )
								result ~= "{ assert( argT, \"argT is null %s %s\" ); assert( arg1, \"arg1 is null %s %s\" ); assert( arg2, \"arg2 is null %s %s\" ); arg1( this ); auto arg1v = %s; arg2( this ); beast.backend.%s.primitiveop.primitiveOp_%s( this, argT, arg1v, %s ); break; }\n".format( packageName,
									opStr, packageName, opStr, packageName, opStr, resultVar, packageName, opStr, resultVar );
							else static if ( params.length == 5 )
								result ~= "{ assert( argT, \"argT is null %s %s\" ); assert( arg1, \"arg1 is null %s %s\" ); assert( arg2, \"arg2 is null %s %s\" ); assert( arg3, \"arg3 is null %s %s\" ); arg1( this ); auto arg1v = %s; arg2( this ); auto arg2v = %s; arg3( this ); beast.backend.%s.primitiveop.primitiveOp_%s( this, argT, arg1v, arg2v, %s ); break; }\n"
									.format( packageName, opStr, packageName, opStr, packageName, opStr, packageName, opStr, resultVar, resultVar, packageName, opStr, resultVar );
						}
						else
							result ~= "assert( 0, \"primitiveOp %s is not implemented for codebuilder.%s\" );\n".format( opStr, packageName );
					}

					result ~= "}\n";
					return result.data;
				}( ) );
			}
		}

}
