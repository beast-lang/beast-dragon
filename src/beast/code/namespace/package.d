module beast.code.namespace;

import beast.code.toolkit;

abstract class Namespace : Identifiable {

public:
	this( Symbol symbol ) {
		symbol_ = symbol;
	}

public:
	/// Symbol this namespace belongs to (for in-function control stmts, it is the function the stmt is in)
	final @property Symbol symbol( ) {
		return symbol_;
	}

	@property string identificationString( ) {
		return symbol.identificationString;
	}

public:
	/// If there are any symbols in this namespace with given identifier, returns them in an overloadset.
	abstract Overloadset resolveIdentifier( Identifier id );

protected:
	static Overloadset[ Identifier ] constructOverloadsets( Symbol[ ] symbolList ) {
		Overloadset[ Identifier ] result;
		// Construct overloadset
		foreach ( sym; symbolList ) {
			assert( sym.identifier );

			if ( auto ptr = sym.identifier in result )
				*ptr ~= sym;
			else
				result[ sym.identifier ] = [ sym ];
		}

		return result;
	}

private:
	Symbol symbol_;

}
