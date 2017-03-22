module beast.code.hwenv.hwenv;

import std.algorithm : min;

/// HardwareEnvironment is in charge of target machine emulation (correct primitive operations etc.)
__gshared HardwareEnvironment hardwareEnvironment;

/// Class representing target hardware environment - responsible for properly emulating primitive operations etc.
abstract class HardwareEnvironment {

public:
	/// Target machine pointer size in bytes
	abstract ubyte pointerSize( );

	/// How many bytes of pointer size are used in interpreter etc
	final ubyte effectivePointerSize() {
		return min( pointerSize, size_t.sizeof );
	}

	/// Target machine max memory size
	abstract size_t memorySize( );

}
