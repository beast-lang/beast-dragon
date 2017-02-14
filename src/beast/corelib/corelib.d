module beast.corelib.corelib;

import beast.corelib.toolkit;
import beast.corelib.decorators.decorators;
import beast.corelib.types.types;

/// Constructs core libraries (if they already are not constructed)
void constructCoreLibrary( ) {
	assert( !coreLibrary );

	coreLibrary = new CoreLibrary( );
}

/// Class containing core libraries symbols
class CoreLibrary {

public:
	/// Core types (primitives, Type, ...)
	CoreLibrary_Types types;

	/// Core decorators
	CoreLibrary_Decorators decorators;

public:
	/// Module where all core stuff is in
	/// This module is not "imported" anywhere; instead, lookup in it is hardwired in the Symbol_Module.resolveIdentifierRecursively
	Symbol_BootstrapModule module_;

public:
	this( ) {
		module_ = new Symbol_BootstrapModule( ExtendedIdentifier.preobtained!"core" );
		Symbol[ ] symbols;
		void delegate( Symbol ) sink = ( s ) { symbols ~= s; };

		types.initialize( module_.namespace, sink );
		decorators.initialize( module_.namespace, sink );

		module_.initialize( symbols );
	}

}

__gshared CoreLibrary coreLibrary;
