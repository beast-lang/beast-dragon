module beast.code.data.decorator.decorator;

import beast.code.data.toolkit;

public {
	import beast.code.ast.decl.variable;
	import beast.code.ast.decl.function_;
}

/// Base class for all decorator types
abstract class Symbol_Decorator : Symbol {

public:
	final override DeclType declarationType( ) {
		return DeclType.decorator;
	}

public:
	final override DataEntity data( DataEntity instance ) {
		assert( 0 );
		// TODO:
	}

public:
	/// Tries to apply in the variableDeclarationModifier context. Returns true if successful
	bool apply_variableDeclarationModifier( VariableDeclarationData data ) {
		return false;
	}

	/// Tries to apply in the functionDeclarationModifier context. Returns true if successful
	bool apply_functionDeclarationModifier( FunctionDeclarationData data ) {
		return false;
	}

}

enum DecorationContext {
	_noContext,

	// AST level contexts: (are applied before symbol creation)
	variableDeclarationModifier, /// For example @static

	// Symbol level contexts: (are applied on symbols)
}
