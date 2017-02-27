module beast.code.ast.decl.env;

import beast.code.toolkit;
import beast.code.data.entitycontainer.scope_.scope_;

/// Implicit declaration arguments
final class DeclarationEnvironment {

public:
	static DeclarationEnvironment newModule( ) {
		DeclarationEnvironment result = new DeclarationEnvironment;
		return result;
	}

	static DeclarationEnvironment newFunctionBody( ) {
		DeclarationEnvironment result = new DeclarationEnvironment;
		result.isStatic = false;
		return result;
	}

public:
	bool isStatic = true;
	bool isCtime = false;

public:
	Symbol_Type parentType;
	EntityContainer parent;

}
