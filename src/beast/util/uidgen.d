module beast.util.uidgen;

import core.atomic;

/// Structure responsible for handling UIDs with thread support (basically an atomic counter)
/// Usage: gen()
struct UIDGenerator {

public:
	size_t opCall( ) {
		return counter_.atomicOp!"+="( 1 );
	}

private:
	shared size_t counter_;

}
