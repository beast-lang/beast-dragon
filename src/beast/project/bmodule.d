module beast.project.bmodule;

import beast.toolkit;
import beast.project.codesource;

/// Abstraction of module in Beast
final class Module : CodeSource {

public:
	this( CTOR_FromFile _, string filename, ExtendedIdentifier identifier ) {
		this.identifier = identifier;
		
		super( _, filename );
	}

public:
	const ExtendedIdentifier identifier;

}
