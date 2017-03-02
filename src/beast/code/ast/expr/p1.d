module beast.code.ast.expr.p1;

import beast.code.ast.toolkit;
import beast.code.ast.expr.atomic;
import beast.code.ast.expr.p1;
import beast.code.ast.expr.auto_;

abstract class AST_P1Expression : AST_Expression {

public:
	static bool canParse( ) {
		return AST_AtomicExpression.canParse;
	}

	static AST_Expression parse( ) {
		if ( AST_AtomicExpression.canParse )
			return AST_AtomicExpression.parse( );

		else if ( AST_AutoExpression.canParse )
			return AST_AutoExpression.parse( );

		currentToken.reportsyntaxError( "expression (P1)" );
		assert( 0 );
	}

public:
	final override bool isP1Expression( ) {
		return true;
	}

}
