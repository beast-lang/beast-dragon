module beast.code.namespace;

import beast.code.toolkit;
import beast.code.symbol.symbol;

/// Class wrapping functionality of a namespace
abstract class Namespace : Identifiable {
	mixin TaskGuard!( "symbolData", SymbolData );

public:
	struct SymbolData {
		Symbol[ ] list;
		Overloadset[ const( Identifier ) ] overloads;
	}

public:
	/// Symbol this namespace belongs to
	abstract @property Symbol relatedSymbol( );

	/// Parent namespace in the hiearchy -- one symbol can contain multiple namespaces
	@property Namespace parentNamespace( ) {
		return relatedSymbol.parentNamespace;
	}

	/// List of all symbols in the namespace
	final @property Symbol[ ] members( ) {
		return _symbolData.list;
	}

protected:
	/// This function should return all symbols in the namespace (by parsing AST and creating proper symbols)
	abstract Symbol[ ] obtain_members( );

private:
	final SymbolData obtain_symbolData( ) {
		SymbolData data;
		data.list = obtain_members( );

		// Construct overloadset
		foreach ( sym; data.list ) {
			assert( sym.identifier );

			auto ptr = sym.identifier in data.overloads;
			if ( ptr )
				*ptr ~= sym;
			else
				data.overloads[ sym.identifier ] = [ sym ];
		}

		return data;
	}

}
