module beast.code.sym.var.staticuser;

import beast.code.sym.toolkit;
import beast.code.sym.var.variable;
import beast.code.sym.var.static_;

/// User (programmer) defined static variable
final class Symbol_StaticUserVariable : Symbol_StaticVariable {
	mixin TaskGuard!"typeDeduction";

public:
	this( AST_VariableDeclaration ast, DecorationList decorationList, VariableDeclarationData data ) {
		ast_ = ast;
		decorationList_ = decorationList;
	}

public:
	override @property BeastType type( ) {
		enforceDone_typeDeduction();
		return type_;
	}

private:
	DecorationList decorationList_;
	AST_VariableDeclaration ast_;
	BeastType type_;

private:
	void execute_typeDeduction( ) {
		type_ = ast_.type.build( ctimeCodeBuilder );
	}

}
