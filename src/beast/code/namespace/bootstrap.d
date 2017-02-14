module beast.code.namespace.bootstrap;

import beast.code.toolkit;
import beast.code.namespace.namespace;

/// Namespace whose symbols are added manually in the compiler code
final class BootstrapNamespace : Namespace {

public:
	this( Symbol symbol ) {
		super( symbol );
	}

	void initialize( Symbol[ ] members ) {
		members_ = members;
		groupedMembers_ = groupMembers( members_ );
	}

public:
	override Symbol[ ] resolveIdentifier( Identifier id ) {
		if ( auto result = id in groupedMembers_ )
			return *result;

		return null;
	}

private:
	Symbol[ ] members_;
	Symbol[ ][ Identifier ] groupedMembers_;

}
