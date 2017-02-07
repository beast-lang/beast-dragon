module beast.corelib.decorators;

import beast.code.symbol.module_;
import beast.code.symbol.decorator.static_;
import beast.code.symbol.module_.bootstrapmodule;
import beast.code.lex.identifier;

struct CoreLibrary_Decorators {

public:
	Symbol_Module module_;
	Symbol_Decorator_Static static_;

public:
	void initialize( ) {
		static_ = new Symbol_Decorator_Static( );

		module_ = new Symbol_BootstrapModule( ExtendedIdentifier.preobtained!"core.decorators", [  //
				static_ //
				 ] );
	}
}
