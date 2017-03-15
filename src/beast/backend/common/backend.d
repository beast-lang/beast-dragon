module beast.backend.common.backend;

import beast.backend.common.codebuilder;

abstract class Backend {

public:
	/// Builds the project using given backend (non-blocking - spawns tasks for it)
	abstract void build( );

	/// As functions are built separately, this function is supposed to spawn a new instance of codebuilder
	abstract CodeBuilder spawnFunctionCodebuilder();

}
