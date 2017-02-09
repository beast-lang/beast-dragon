module beast.code.overloadset;

import beast.code.toolkit;

/// Structure containing multiple symbols and providing support for filtering them etc
struct Overloadset {

public:
	this( Symbol sym ) {
		this.data = [ sym ];
	}

	this( Symbol[ ] data ) {
		this.data = data;
	}

public:
	@property bool isEmpty( ) {
		return data.length == 0;
	}

public:
	/// Filters all decorators from the overloadset and returns them
	Symbol_Decorator[ ] filterDecorators( ) {
		return data.filter!( x => x.baseType == Symbol.BaseType.decorator ).map!( x => cast( Symbol_Decorator ) x ).array;
	}

public:
	Symbol[ ] data;
	alias data this;

}
