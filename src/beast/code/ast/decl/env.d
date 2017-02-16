module beast.code.ast.decl.env;

import beast.code.toolkit;

/// Implicit declaration arguments
final class DeclarationEnvironment {

public:
	static DeclarationEnvironment newModule() {
		DeclarationEnvironment result = new DeclarationEnvironment;
		return result;
	}

public:
	bool isStatic = true;
	bool isCtime = false;

public:
	Namespace parentNamespace;
	Symbol_Type parentType;

}