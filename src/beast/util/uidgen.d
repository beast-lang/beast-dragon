module beast.util.uidgen;

import core.atomic;
import core.sync.mutex;

/// Structure responsible for handling UIDs with thread support (basically an atomic counter)
/// Usage: gen()
struct UIDGenerator {

public:
	/// Generates the UID and returns it
	size_t opCall( ) {
		return counter_.atomicOp!"+="( 1 );
	}

private:
	shared size_t counter_;

}

/// Structure responsible for assigning UIDs to instances and keeping track of mapping UIDs to instances
/// YOU HAVE TO CALL .initialize !!!
struct UIDKeeper( Type ) if ( is( Type == class ) || is( Type == interface ) ) {

public:
	void initialize( ) {
		mutex = new Mutex;
	}

public:
	/// Generates the UID, assigns it with the object and returns it
	size_t opCall( Type obj ) {
		synchronized ( mutex ) {
			counter++;
			map[ counter ] = obj;
			return counter;
		}
	}

	/// Return object asssigned with the UID or null
	Type opIndex( size_t uid ) {
		synchronized ( mutex ) {
			if ( auto result = uid in map )
				return *result;

			return null;
		}
	}

private:
	size_t counter;
	Type[ size_t ] map;
	Mutex mutex;

}
