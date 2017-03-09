module beast.corelib.deco.decorators;

import beast.corelib.toolkit;
import beast.corelib.deco.static_;

struct CoreLibrary_Decorators {

	public:
		Symbol_Decorator_Static static_;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			sink( static_ = new Symbol_Decorator_Static( parent ) );
		}
}
