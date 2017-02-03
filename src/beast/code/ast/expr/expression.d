module beast.code.ast.expr.expression;

import beast.code.ast.toolkit;

abstract class AST_Expression : ASTNode {

public:
	static bool canParse( ) {
		return AST_P1Expression.canParse;
	}

	static AST_Expression parse( ) {
		return AST_P1Expression.parse( );
	}

}
