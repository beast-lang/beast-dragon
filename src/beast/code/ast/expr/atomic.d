module beast.code.ast.expr.atomic;

import beast.code.ast.toolkit;
import beast.code.ast.expr.identifierbase;
import beast.code.ast.expr.parentcomma;

abstract class AST_AtomicExpression : AST_Expression {

	public:
		static bool canParse( ) {
			return AST_IdentifierBaseExpression.canParse || AST_ParentCommaExpression.canParse;
		}

		static AST_Expression parse( ) {
			if ( AST_IdentifierBaseExpression.canParse )
				return AST_IdentifierBaseExpression.parse( );

			else if ( AST_ParentCommaExpression.canParse )
				return AST_ParentCommaExpression.parse( );

			currentToken.reportsyntaxError( "expression (atomic)" );
			assert( 0 );
		}

	public:
		final override bool isP1Expression( ) {
			return true;
		}

}
