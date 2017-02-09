module beast.code.sym.var.user;

import beast.code.sym.toolkit;
import beast.code.sym.var.variable;
import beast.code.ast.decl.variable;

/// User (programmer) defined variable
final class Symbol_UserVariable : Symbol_Variable {
	mixin TaskGuard!"decorators_variableDeclarationModifier_application";

public:
	this( AST_VariableDeclaration ast ) {
		ast_ = ast;
		decorationList_ = new DecorationList( ast_.decorationList );
	}

public:
	override @property Symbol_Type type( ) {
		assert( 0 );
	}

	override @property bool isStatic( ) {
		return isStatic_;
	}

public:
	bool isStatic_;
	Symbol_Type type_;
	DecorationList decorationList_;
	AST_VariableDeclaration ast_;

private:
	void execute_decorators_variableDeclarationModifier_application( ) {
		decorationList_.apply_variableModifier( this );
	}

}
