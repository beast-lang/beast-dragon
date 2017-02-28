module beast.code.data.decorator.decorator;

import beast.code.data.toolkit;

public {
	import beast.code.ast.decl.variable;
	import beast.code.ast.decl.function_;
}

/// Base class for all decorator types
abstract class Symbol_Decorator : Symbol {

public:
	this( DataEntity parent ) {
		parent_ = parent;
	}

public:
	final override DeclType declarationType( ) {
		return DeclType.decorator;
	}

public:
	final override DataEntity dataEntity( DataEntity parentInstance = null ) {
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

	/// Attempts to apply the decorator in the typeDecorator context. Returns true if successfull.
	/// Type decorator takes one type and returns another
	bool apply_typeWrapper( ref Symbol_Type type ) {
		return false;
	}

private:
	DataEntity parent_;

}

enum DecorationContext {
	_noContext,

	// AST level contexts: (are applied before symbol creation)
	variableDeclarationModifier, /// For example @static

	// Symbol level contexts: (are applied on symbols)
}
