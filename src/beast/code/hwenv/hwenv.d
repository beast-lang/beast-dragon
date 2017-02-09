module beast.code.hwenv.hwenv;

/// HardwareEnvironment is in charge of target machine emulation (correct primitive operations etc.)
__gshared HardwareEnvironment hardwareEnvironment;

/// Class representing target hardware environment - responsible for properly emulating primitive operations etc.
abstract class HardwareEnvironment {

public:
	/// Target machine pointer size in bytes
	abstract @property ubyte pointerSize( );

	/// Target machine max memory size
	abstract @property size_t memorySize( );

}
