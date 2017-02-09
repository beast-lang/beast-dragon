module beast.code.sym.var.variable;

import beast.code.toolkit;

abstract class Symbol_Variable : Symbol {

public:
	final override @property BaseType baseType( ) {
		return BaseType.variable;
	}

public:
	/// Type of the variable
	abstract @property Symbol_Type type( );

	/// If the variable value is known at compile time
	abstract @property bool isCtime( );

	/// If the variable is static or requires context (instance of symbol parent)
	abstract @property bool isStatic( );

public:
	override Overloadset resolveIdentifier( Identifier id ) {
		if ( auto result = super.resolveIdentifier( id ) )
			return result;

		// Special case - core.Type; maybe there's more elegant way how to do this?
		if ( type !is this ) {
			// Look into namespace of type of this variable
			if ( auto result = type.resolveIdentifier( id ) )
				return result;
		}

		return Overloadset( );
	}

}
