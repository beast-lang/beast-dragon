module beast.backend.common.backend;

import beast.backend.toolkit;
import beast.backend.common.codebuilder;

abstract class Backend {

	public:
		/// Builds the project using given backend (non-blocking - spawns tasks for it)
		abstract void build( );

		/// As functions are built separately, this function is supposed to spawn a new instance of codebuilder
		abstract CodeBuilder spawnFunctionCodebuilder( );

	public:
		/// Includes definition of given runtime function in the output code
		abstract void buildRuntimeFunction( Symbol_RuntimeFunction func );

		/// Includes declaration of given type in the output code (no member functions, only the type itself)
		abstract void buildType( Symbol_Type type );

}
