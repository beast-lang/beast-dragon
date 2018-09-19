module beast.code.hwenv.hwenv;

import std.algorithm : min;

/// HardwareEnvironment is in charge of target machine emulation (correct primitive operations etc.)
__gshared HardwareEnvironment hardwareEnvironment;

/// Class representing target hardware environment - responsible for properly emulating primitive operations etc.
abstract class HardwareEnvironment {

protected:
	this(ubyte pointerSize, size_t memorySize) {
		this.pointerSize = pointerSize;
		this.memorySize = memorySize;

		effectivePointerSize = min(pointerSize, size_t.sizeof);
	}

public:
	/// Target machine pointer size in bytes
	const ubyte pointerSize;

	/// How many bytes of pointer size are used in interpreter etc
	const ubyte effectivePointerSize;

	/// Target machine max memory size
	const size_t memorySize;

}
