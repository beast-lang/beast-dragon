module beast.backend.common.backend;

abstract class Backend {

public:
	/// Builds the project using given backend (non-blocking - spawns tasks for it)
	abstract void build( );

}
