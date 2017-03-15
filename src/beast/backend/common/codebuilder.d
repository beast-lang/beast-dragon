module beast.backend.common.codebuilder;

import beast.backend.toolkit;
import beast.util.identifiable;

/// Root class for building code with any backend
abstract class CodeBuilder : Identifiable {

	public:
		/// When called, StmtFunction should build given part of the statement using provided codebuilder
		alias StmtFunction = void delegate( CodeBuilder cb );

		/// When called, DeclFunction should build relevant declarations using provided codebuilder
		alias DeclFunction = void delegate( CodeBuilder cb );

	public: // Declaration related build commands
		void build_moduleDefinition( Symbol_Module module_, DeclFunction content ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_localVariableDefinition( DataEntity_LocalVariable var ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_typeDefinition( Symbol_Type type, DeclFunction content ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

	public: // Expression related build commands
		/// Builds access to a memory (passed by a pointer)
		/// The memory doesn't have to be static! You have to check associated memory block flags (it can be local ctime variable or so)
		void build_memoryAccess( MemoryPtr pointer ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		/// Builds write to a memory
		void build_memoryWrite( DataScope scope_, MemoryPtr target, DataEntity data ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		final void build_memoryWrite( DataScope scope_, MemoryPtr target, Symbol sym ) {
			build_memoryWrite( scope_, target, sym.dataEntity );
		}

		void build_functionCall( DataScope scope_, Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_primitiveOperation( DataScope scope_, Symbol_RuntimeFunction wrapperFunction, BackendPrimitiveOperation op, DataEntity parentInstance, DataEntity[ ] arguments ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

	public: // Statement related build commands
		/// Builds the "if" construction
		/// Condition has to be of type bool
		/// elseBranch can be null
		void build_if( DataScope scope_, DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

	public:
		final void build_copyCtor( DataEntity_LocalVariable var, DataEntity initValue, DataScope scope_ ) {
			var.expectResolveIdentifier( ID!"#ctor", scope_ ).resolveCall( scope_, var.ast, true, coreLibrary.enum_.xxctor.copy, initValue ).buildCode( this, scope_ );
		}

	protected:
		/// Creates a new scope (scopes are stored on a stack)
		/// CodeBuilder scopes are used for destructor generating
		void pushScope( ) {
			scopeStack_ ~= topScope_;
			topScope_ = null;
		}

		/// Destroys the last scope
		/// CodeBuilder scopes are used for destructor generating
		void popScope( ) {
			// TODO: generate destructors

			assert( scopeStack_.length );

			topScope_ = scopeStack_[ $ - 1 ];
			scopeStack_.length--;
		}

		final void addToScope( DataEntity_LocalVariable var ) {
			topScope_ ~= var;
		}

		final DataEntity_LocalVariable[ ] scopeItems( ) {
			return topScope_;
		}

	private:
		DataEntity_LocalVariable[ ] topScope_;
		// There should always be one empty scope - for optimizations
		DataEntity_LocalVariable[ ][ ] scopeStack_ = [ [ ] ];

}
