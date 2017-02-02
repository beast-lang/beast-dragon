module beast.code.namespace;

import beast.code.toolkit;
import beast.code.symbol.symbol;

/// Class wrapping functionality of a namespace
abstract class Namespace : Identifiable {
	mixin TaskGuard!( "symbolData", SymbolData );

public:
	struct SymbolData {
		Symbol[ ] list;
		Overloadset[ const( Identifier ) ] overloadsets;
	}

public:
	/// Symbol this namespace belongs to (for in-function control stmts, it is the function the stmt is in)
	abstract @property Symbol relatedSymbol( );

	/// Parent namespace in the hiearchy -- one symbol can contain multiple namespaces
	@property Namespace parentNamespace( ) {
		return relatedSymbol.parentNamespace;
	}

	/// List of all symbols in the namespace
	final @property Symbol[ ] members( ) {
		return symbolData.list;
	}

	/// All symbols in the namespace grouped into overloads by identifier
	final @property Overloadset[ const( Identifier ) ] overloadsets( ) {
		return symbolData.overloadsets;
	}

	/// Grouped symbol data
	alias symbolData = _symbolData;

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

			auto ptr = sym.identifier in data.overloadsets;
			if ( ptr )
				*ptr ~= sym;
			else
				data.overloadsets[ sym.identifier ] = [ sym ];
		}

		return data;
	}

}
