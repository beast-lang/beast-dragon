module beast.code.sym.decorator.decorator;

import beast.code.sym.toolkit;

public {
	import beast.code.ast.decl.variable;
}

/// Base class for all decorator types
abstract class Symbol_Decorator : Symbol {

public:
	this( Namespace parentNamespace ) {
		parentNamespace_ = parentNamespace;
	}

public:
	final override @property DeclType declarationType( ) {
		return DeclType.decorator;
	}

	final override @property Namespace parentNamespace( ) {
		return parentNamespace_;
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

private:
	Namespace parentNamespace_;

}

enum DecorationContext {
	_noContext,

	// AST level contexts: (are applied before symbol creation)
	variableDeclarationModifier, /// For example @static

	// Symbol level contexts: (are applied on symbols)
}
