module beast.backend.common.backend;

import beast.backend.toolkit;
import beast.backend.common.codebuilder;

abstract class Backend {

public:
	/// Builds the project using given backend (non-blocking - spawns tasks for it)
	/// Called from main function (and thread)
	abstract void build();

	/// As functions are built separately, this function is supposed to spawn a new instance of codebuilder
	/// This function is called asynchronously
	abstract CodeBuilder spawnFunctionCodebuilder();

public:
	/// Builds code to be executed BEFORE the main function
	/// Order of code execution must correspond with order of this code calls
	/// This function is called asynchronously
	abstract void buildInitCode(CodeBuilder.StmtFunction func);

public:
	/// Includes definition of given runtime function in the output code
	/// This function is called asynchronously
	abstract void buildRuntimeFunction(Symbol_RuntimeFunction func);

	/// Includes declaration of given type in the output code (no member functions, only the type itself)
	/// This function is called asynchronously
	abstract void buildType(Symbol_Type type);

}
