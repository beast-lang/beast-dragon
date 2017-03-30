module beast.code.hwenv.native;

import beast.code.hwenv.hwenv;

/// Native (current machine) hardware environment
final class HardwareEnvironment_Native : HardwareEnvironment {

	public:
		this( ) {
			super( size_t.sizeof, size_t.max );
		}

}
