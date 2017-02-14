module beast.code.ast.decl.env;

import beast.toolkit;

/// Implicit declaration arguments
final class DeclarationEnvironment {

public:

public:
	bool isStatic = true;
	bool isCtime = false;
	SymbolEnvironmentType envType = SymbolEnvironmentType.static_;

}

__gshared DeclarationEnvironment declarationEnvironment_module;

private enum _init = HookAppInit.hook!( {
		declarationEnvironment_module = new DeclarationEnvironment;
	} );

enum SymbolEnvironmentType {
	static_, /// No context, no stack
	local, /// On stack - requires stack pointer
	member /// Requires context pointer passed somehow
}
