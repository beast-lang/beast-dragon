module beast.code.data.overloadset;

import beast.code.data.toolkit;

struct Overloadset {

public:
	DataEntity[ ] data;

public:
	/// Filters out only decorators from the overloadset
	Symbol_Decorator[ ] filterDecorators( ) {
		assert( 0 );
		// TODO:
	}

public:
	bool opCast( T : bool )( ) const {
		return data.length > 0;
	}

}
