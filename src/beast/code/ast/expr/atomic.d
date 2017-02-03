module beast.code.ast.expr.atomic;

import beast.code.ast.toolkit;
import beast.code.ast.expr.identifierbase;

abstract class AST_AtomicExpression : AST_Expression {

public:
	static bool canParse( ) {
		return AST_IdentifierBaseExpression.canParse;
	}

	static AST_Expression parse( ) {
		if ( AST_IdentifierBaseExpression.canParse )
			return AST_IdentifierBaseExpression.parse( );

		currentToken.reportUnexpectedToken( "expression (atomic)" );
		assert( 0 );
	}
}
