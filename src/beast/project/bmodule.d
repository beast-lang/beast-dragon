module beast.project.bmodule;

import beast.toolkit;
import beast.project.codesource;
import std.regex;

/// Abstraction of module in Beast
final class Module : CodeSource {

public:
	this( CTOR_FromFile _, string filename, ExtendedIdentifier identifier ) {
		this.identifier = identifier;

		super( _, filename );

		import std.stdio;

		writeln( "New module " ~ identifier.str );
	}

public:
	const ExtendedIdentifier identifier;

}

bool isValidModuleOrPackageIdentifier( string str ) {
	static auto rx = ctRegex!"^[a-z_][a-z0-9_]*$";
	return cast( bool ) str.matchFirst( rx );
}
