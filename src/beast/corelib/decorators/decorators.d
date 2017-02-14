module beast.corelib.decorators.decorators;

import beast.corelib.toolkit;
import beast.corelib.decorators.static_;

struct CoreLibrary_Decorators {

public:
	Symbol_Decorator_Static static_;

public:
	void initialize( Namespace nmspc, void delegate( Symbol ) sink ) {
		sink( static_ = new Symbol_Decorator_Static( nmspc ) );
	}
}
