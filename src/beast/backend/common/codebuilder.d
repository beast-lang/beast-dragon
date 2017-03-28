module beast.backend.common.codebuilder;

import beast.backend.toolkit;
import beast.util.identifiable;

/// Root class for building code with any backend
abstract class CodeBuilder : Identifiable {

	public:
		/// When called, StmtFunction should build given part of the statement using provided codebuilder
		alias StmtFunction = void delegate( CodeBuilder cb );

		/// When called, StmtFunction should build expression using provided codebuilder		
		alias ExprFunction = void delegate( CodeBuilder cb );

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

		/// Builds write to a memory
		void build_memoryWrite( MemoryPtr target, DataEntity data ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		final void build_memoryWrite( MemoryPtr target, Symbol sym ) {
			build_memoryWrite( target, sym.dataEntity );
		}

		void build_functionCall( Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_primitiveOperation( BackendPrimitiveOperation op, Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null ) {
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

	public: // Statement related build commands
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
			var.expectResolveIdentifier( ID!"#ctor" ).resolveCall( var.ast, true, coreLibrary.enum_.xxctor.opAssign, initValue ).buildCode( this );
		}

		final void build_dtor( DataEntity_LocalVariable var ) {
			var.expectResolveIdentifier( ID!"#dtor" ).resolveCall( null, true ).buildCode( this );
		}

	protected:
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

			scopeStack_.length--;
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

}
