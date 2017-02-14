module beast.code.sym.var.userstatic;

import beast.code.sym.toolkit;
import beast.code.sym.var.variable;
import beast.code.sym.var.static_;

/// User (programmer) defined static variable
final class Symbol_UserStaticVariable : Symbol_StaticVariable {
	mixin TaskGuard!"typeDeduction";

public:
	this( AST_VariableDeclaration ast, DecorationList decorationList, DeclarationEnvironment env ) {
		super( env.parentNamespace );

		ast_ = ast;
		decorationList_ = decorationList;
	}

public:
	override @property Identifier identifier( ) {
		return ast_.identifier;
	}

	override @property Symbol_Type dataType( ) {
		enforceDone_typeDeduction( );
		return type_;
	}

private:
	DecorationList decorationList_;
	AST_VariableDeclaration ast_;
	Symbol_Type type_;

private:
	void execute_typeDeduction( ) {
		//type_ = ast_.type.build( ctimeCodeBuilder );
		// TODO:
	}

}
