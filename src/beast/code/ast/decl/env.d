module beast.code.ast.decl.env;

import beast.code.toolkit;

/// Implicit declaration arguments
final class DeclarationEnvironment {

public:

public:
	bool isStatic = true;
	bool isCtime = false;

public:
	Namespace parentNamespace;
	Symbol_Type parentType;

}

__gshared DeclarationEnvironment declarationEnvironment_module;

private enum _init = HookAppInit.hook!( {
		declarationEnvironment_module = new DeclarationEnvironment;
	} );