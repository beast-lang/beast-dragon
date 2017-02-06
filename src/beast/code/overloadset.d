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
	Symbol[ ] data;
	alias data this;

}
