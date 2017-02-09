module beast.code.hwenv.native;

import beast.code.hwenv.hwenv;

/// Native (current machine) hardware environment
final class HardwareEnvironment_Native : HardwareEnvironment {

public:
	override @property ubyte pointerSize( ) {
		return size_t.sizeof;
	}

	override @property size_t memorySize( ) {
		return size_t.max;
	}

}
