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
		final void build_memoryWrite( DataScope scope_, MemoryPtr target, DataEntity data ) {
			if ( data.isCtime )
				_build_memoryWrite( target, data.ctExec( scope_ ), data.dataType.instanceSize );
			else
				_build_memoryWrite( scope_, target, data );
		}

		final void build_memoryWrite( DataScope scope_, MemoryPtr target, Symbol sym ) {
			build_memoryWrite( scope_, target, sym.dataEntity );
		}

		protected void _build_memoryWrite( DataScope scope_, MemoryPtr target, DataEntity data ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		protected void _build_memoryWrite( MemoryPtr target, MemoryPtr data, size_t dataSize ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

		void build_functionCall( DataScope scope_, Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

	public: // Statement related build commands
		/// Builds the "if" construction
		/// Condition has to be of type bool
		/// elseBranch can be null
		void build_if( DataScope scope_, DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
			assert( 0, "%s not implemented for %s".format( __FUNCTION__, identificationString ) );
		}

}
