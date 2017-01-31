module beast.code.symbol.symbol;

import beast.code.symbol.toolkit;

/// Base class for all symbols
abstract class Symbol : Identifiable {

public:
	/// Parent namespace of a symbol
	Namespace parentNamespace;

public:
	/// Location of where in the code the symbol was declared (or code that +- matches it)
	@property CodeLocation codeLocation( ) const;

	/// Identifier of the symbol, may be null (for template instances, anonymous functions etc.)
	@property const( Identifier ) identifier( ) const {
		return null;
	}

	/// For template instances, the base name is the template identifier; otherwise it is equal to identifier
	@property const( Identifier ) baseName( ) const {
		return identifier;
	}

public:
	override @property string identificationString( ) const {
		return parentNamespace ? parentNamespace.identificationString ~ "." ~ baseName.str : baseName.str;
	}

}
