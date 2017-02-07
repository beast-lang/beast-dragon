module beast.corelib;

import beast.code.symbol.module_;
import beast.corelib.decorators;

/// Constructs core libraries (if they already are not constructed)
void constructCoreLibraries( ) {
	assert( !coreLibraries );
	
	coreLibraries = new CoreLibraries( );
}

/// Class containing core libraries symbols
class CoreLibraries {

public:
	// List of all core libraries modules
	Symbol_Module[ ] moduleList;

	/// Core decorators
	CoreLibrary_Decorators decorators;

public:
	this( ) {
		decorators.initialize( );

		moduleList = [ decorators.module_ ];
	}

};

__gshared CoreLibraries coreLibraries;
