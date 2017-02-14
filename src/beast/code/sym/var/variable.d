module beast.code.sym.var.variable;

import beast.code.toolkit;

abstract class Symbol_Variable : Symbol {

public:
	final override @property BaseType baseType( ) {
		return BaseType.variable;
	}

public:
	/// Type of the variable
	abstract @property BeastType type( );

	/// Whether the variable is static, stack-local or context-dependent
	abstract @property SymbolEnvironmentType envType( );

	/// If the variable value is known at compile time
	@property bool isCtime( ) {
		return false;
	}

	/// Pointer to ctime data, if the variable is ctime
	/// Ctime have to be of type type
	abstract MemoryPtr ctimeData( MemoryPtr contextPointer ) {
		assert( 0 );
	}

	/// If the variable is static or requires context (instance of symbol parent)
	final @property bool requiresContext( ) {
		return envType == SymbolEnvironmentType.member;
	}

public:
	override Overloadset resolveIdentifier( Identifier id ) {
		if ( auto result = super.resolveIdentifier( id ) )
			return result;

		// Look into namespace of type of this variable
		if ( auto result = type.resolveIdentifier( id, ctimeData( nullMemoryPtr ) ) )
			return result;

		return Overloadset( );
	}

}
