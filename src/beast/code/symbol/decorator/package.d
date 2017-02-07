module beast.code.symbol.decorator;

import beast.code.symbol.toolkit;
import beast.code.symbol.vardecldata;

/// Base class for all decorator types
abstract class Symbol_Decorator : Symbol {

public:
	/// First level of decoration resolutio -- this function is used when checking decorators on AST-level context
	/// Returns lowest possible level this context can be applied on
	abstract DecorationContext canBeAppliedOn( DecoratorASTLevelApplication application );

public:
	/// Applies the decorator on variable declaration
	void apply( VariableDeclarationData data ) {
		assert( 0 );
	}

}

enum DecorationContext {
	_noContext,

	// AST level contexts: (are applied before symbol creation)
	variableDeclarationModifier, /// For example @static

	// Symbol level contexts: (are applied on symbols)
}

enum DecoratorASTLevelApplication {
	variableDeclaration,
	importDeclaration,
	classDeclaration,
	functionDeclaration
}