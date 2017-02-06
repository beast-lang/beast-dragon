module beast.code.symbol;

import beast.code.symbol.toolkit;

/// Base class for all symbols
abstract class Symbol : Identifiable {

public:
	/// Parent namespace of a symbol
	Namespace parentNamespace;

public:
	/// Location of where in the code the symbol was declared (or code that +- matches it)
	@property CodeLocation codeLocation( );

	/// Identifier of the symbol, may be null (for template instances, anonymous functions etc.)
	@property Identifier identifier( ) {
		return null;
	}

	/// For template instances, the base name is the template identifier; otherwise it is equal to identifier
	@property Identifier baseName( ) {
		return identifier;
	}

public:
	override @property string identificationString( ) {
		return parentNamespace ? parentNamespace.identificationString ~ "." ~ baseName.str : baseName.str;
	}

}
