module beast.corelib.corelib;

import beast.corelib.toolkit;
import beast.corelib.decorators.decorators;
import beast.corelib.type;

/// Constructs core libraries (if they already are not constructed)
void constructCoreLibrary( ) {
	assert( !coreLibrary );

	coreLibrary = new CoreLibrary( );
}

/// Class containing core libraries symbols
class CoreLibrary {

public:
	/// Type 'Type' -- typeof all classes etc.
	Symbol_Type_Type Type;

	/// Core decorators
	CoreLibrary_Decorators decorators;

public:
	// Module where all core stuff is in
	Symbol_BootstrapModule module_;

public:
	this( ) {
		Symbol[ ] symbols;
		void delegate( Symbol ) sink = ( s ) { symbols ~= s; };

		sink( Type = new Symbol_Type_Type );
		decorators.initialize( sink );

		module_ = new Symbol_BootstrapModule( ExtendedIdentifier.preobtained!"core", symbols );
	}

}

__gshared CoreLibrary coreLibrary;
