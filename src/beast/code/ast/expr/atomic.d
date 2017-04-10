module beast.code.ast.expr.atomic;

import beast.code.ast.toolkit;
import beast.code.ast.expr.identifierbase;
import beast.code.ast.expr.parentcomma;
import beast.code.ast.expr.literal;

abstract class AST_AtomicExpression : AST_Expression {

	public:
		pragma( inline ) static bool canParse( ) {
			return AST_IdentifierBaseExpression.canParse || AST_ParentCommaExpression.canParse || AST_LiteralExpression.canParse;
		}

		static AST_Expression parse( ) {
			if ( AST_LiteralExpression.canParse )
				return AST_LiteralExpression.parse( );

			else if ( AST_IdentifierBaseExpression.canParse )
				return AST_IdentifierBaseExpression.parse( );

			else if ( AST_ParentCommaExpression.canParse )
				return AST_ParentCommaExpression.parse( );

			currentToken.reportSyntaxError( "expression (atomic)" );
			assert( 0 );
		}

	public:
		final override bool isPrefixExpression( ) {
			return true;
		}

}
