module beast.code.usernamespace;

import beast.code.toolkit;

/// Class wrapping functionality of a namespace
final class UserNamespace : Identifiable {
	mixin TaskGuard!( "symbolData" );

public:
	this( Symbol symbol, Symbol[ ]delegate( ) obtainFunction ) {
		symbol_ = symbol;
		obtainFunction_ = obtainFunction;
	}

public:
	/// Symbol this namespace belongs to (for in-function control stmts, it is the function the stmt is in)
	@property Symbol symbol( ) {
		return symbol_;
	}

	@property string identificationString( ) {
		return symbol.identificationString;
	}

	/// List of all symbols in the namespace
	final @property Symbol[ ] members( ) {
		enforce_symbolData( );
		return members_;
	}

	/// All symbols in the namespace grouped into overloads by identifier
	final @property Overloadset[ Identifier ] overloadsets( ) {
		enforce_symbolData( );
		return memberOverloadsets_;
	}

private:
	final void obtain_symbolData( ) {
		members_ = obtainFunction_( );

		// Construct overloadset
		foreach ( sym; members_ ) {
			assert( sym.identifier );

			if ( auto ptr = sym.identifier in memberOverloadsets_ )
				*ptr ~= sym;
			else
				memberOverloadsets_[ sym.identifier ] = [ sym ];
		}
	}

private:
	Symbol symbol_;
	Symbol[ ] members_;
	Overloadset[ Identifier ] memberOverloadsets_;
	Symbol[ ]delegate( ) obtainFunction_;

}
