module beast.code.namespace;

import beast.code.toolkit;

/// Class wrapping functionality of a namespace
abstract class Namespace : Identifiable {
	mixin TaskGuard!( "symbolData" );

public:
	/// Symbol this namespace belongs to (for in-function control stmts, it is the function the stmt is in)
	abstract @property Symbol relatedSymbol( );

	@property string identificationString( ) {
		return relatedSymbol.identificationString;
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

protected:
	/// This function should return all symbols in the namespace (by parsing AST and creating proper symbols)
	abstract Symbol[ ] obtain_members( );

private:
	final void obtain_symbolData( ) {
		members_ = obtain_members( );

		// Construct overloadset
		foreach ( sym; members_ ) {
			assert( sym.identifier );

			auto ptr = sym.identifier in memberOverloadsets_;
			if ( ptr )
				*ptr ~= sym;
			else
				memberOverloadsets_[ sym.identifier ] = [ sym ];
		}
	}

private:
	Symbol[ ] members_;
	Overloadset[ Identifier ] memberOverloadsets_;

}
