module beast.code.sym.decorator.decorator;

import beast.code.sym.toolkit;

public {
	import beast.code.ast.decl.variable;
}

/// Base class for all decorator types
abstract class Symbol_Decorator : Symbol {

public:
	final override @property BaseType baseType( ) {
		return BaseType.decorator;
	}

public:
	/// Tries to apply in the variableDeclarationModifier context. Returns true if successful
	bool apply_variableDeclarationModifier( VariableDeclarationData data ) {
		return false;
	}

}

enum DecorationContext {
	_noContext,

	// AST level contexts: (are applied before symbol creation)
	variableDeclarationModifier, /// For example @static

	// Symbol level contexts: (are applied on symbols)
}