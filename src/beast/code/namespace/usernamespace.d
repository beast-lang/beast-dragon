module beast.code.namespace.usernamespace;

import beast.code.toolkit;
import beast.code.namespace;

/// Namespace whose symbols are generated from user (programmer) code
final class UserNamespace : Namespace {
	mixin TaskGuard!( "symbolData" );

public:
	this( Symbol symbol, Symbol[ ]delegate( ) obtainFunction ) {
		super( symbol );
		obtainFunction_ = obtainFunction;
	}

public:
	override Overloadset resolveIdentifier( Identifier id ) {
		enforce_symbolData();
		if ( auto result = id in memberOverloadsets_ )
			return *result;

		return Overloadset( );
	}

private:
	final void obtain_symbolData( ) {
		members_ = obtainFunction_( );
		memberOverloadsets_ = constructOverloadsets( members_ );

		// Automatically set parent of member symbols
		foreach ( mem; members_ ) {
			assert( !mem.parent );
			mem.parent = symbol;
		}
	}

private:
	Symbol symbol_;
	Symbol[ ] members_;
	Overloadset[ Identifier ] memberOverloadsets_;
	Symbol[ ]delegate( ) obtainFunction_;

}
