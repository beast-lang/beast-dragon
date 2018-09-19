module beast.corelib.deco.decorators;

import beast.corelib.toolkit;
import beast.corelib.deco.static_;
import beast.corelib.deco.ctime;

struct CoreLibrary_Decorators {

public:
	Symbol_Decorator_Ctime ctime_;
	Symbol_Decorator_Static static_;

public:
	void initialize(void delegate(Symbol) sink, DataEntity parent) {
		sink(ctime_ = new Symbol_Decorator_Ctime(parent));
		sink(static_ = new Symbol_Decorator_Static(parent));
	}
}
