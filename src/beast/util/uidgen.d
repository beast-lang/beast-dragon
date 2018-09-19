module beast.util.uidgen;

import core.sync.mutex : Mutex;
import core.atomic : atomicOp;

/// Structure responsible for handling UIDs with thread support (basically an atomic counter)
/// Usage: gen()
struct UIDGenerator {

public:
	alias I = uint;

public:
	/// Generates the UID and returns it
	pragma(inline) I opCall() {
		assert(counter_ != 0, "UIDGen overflow");
		return counter_.atomicOp!"+="(1);
	}

private:
	shared I counter_ = 1;

}

/// Structure responsible for assigning UIDs to instances and keeping track of mapping UIDs to instances
/// YOU HAVE TO CALL .initialize !!!
struct UIDKeeper(Type) if (is(Type == class) || is(Type == interface)) {

public:
	alias I = UIDGenerator.I;

public:
	void initialize() {
		mutex = new Mutex;
	}

public:
	/// Generates the UID, assigns it with the object and returns it
	I opCall(Type obj) {
		synchronized (mutex) {
			counter++;
			map[counter] = obj;
			return counter;
		}
	}

	/// Return object asssigned with the UID or null
	Type opIndex(uint uid) {
		synchronized (mutex) {
			if (auto result = uid in map)
				return *result;

			return null;
		}
	}

private:
	I counter = 1;
	Type[I] map;
	Mutex mutex;

}
