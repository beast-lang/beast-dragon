module beast.code.namespace.bootstrapnamespace;

import beast.code.toolkit;
import beast.code.namespace;

/// Namespace whose symbols are added manually in the compiler code
final class BootstrapNamespace : Namespace {

public:
	this( Symbol symbol, Symbol[ ] members ) {
		super( symbol );
		members_ = members;
		memberOverloadsets_ = constructOverloadsets( members_ );

		// Automatically set parent of member symbols
		foreach ( mem; members_ ) {
			assert( !mem.parent );
			mem.parent = symbol;
		}
	}

public:
	override Overloadset resolveIdentifier( Identifier id ) {
		if ( auto result = id in memberOverloadsets_ )
			return *result;

		return Overloadset( );
	}

private:
	Symbol[ ] members_;
	Overloadset[ Identifier ] memberOverloadsets_;

}
