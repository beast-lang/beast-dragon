module beast.corelib.corelib;

import beast.corelib.toolkit;
import beast.corelib.types.types;
import beast.corelib.decorators.decorators;
import beast.corelib.constants;
import beast.code.data.module_.bootstrap;
import beast.code.lex.identifier;

/// Constructs core libraries (if they already are not constructed)
void constructCoreLibrary( ) {
	assert( !coreLibrary );

	coreLibrary = new CoreLibrary;
	coreLibrary.initialize( );
}

/// Class containing core libraries symbols
class CoreLibrary {

	public:
		/// Core types (primitives, Type, ...)
		CoreLibrary_Types types;

		/// Core decorators (static, ctime, ...)
		CoreLibrary_Decorators decorators;

		/// Core constants (true, false, ...)
		CoreLibrary_Constants constants;

	public:
		/// Module where all core stuff is in
		/// This module is not "imported" anywhere; instead, lookup in it is hardwired in the Symbol_Module.recursivelyResolveIdentifier
		Symbol_BootstrapModule module_;

	public:
		void initialize( ) {
			module_ = new Symbol_BootstrapModule( ExtendedIdentifier.preobtained!"core" );
			Symbol[ ] symbols;
			void delegate( Symbol ) sink = ( s ) { symbols ~= s; };

			types.initialize( sink, module_.dataEntity );
			constants.initialize( sink, module_.dataEntity );
			decorators.initialize( sink, module_.dataEntity );

			module_.initialize( symbols );
		}

}

__gshared CoreLibrary coreLibrary;
