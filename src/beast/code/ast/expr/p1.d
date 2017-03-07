module beast.code.ast.expr.p1;

import beast.code.ast.toolkit;
import beast.code.ast.expr.atomic;
import beast.code.ast.expr.auto_;
import beast.code.ast.expr.parentcomma;
import beast.code.ast.expr.p1_dotident;

final class AST_P1Expression : AST_Expression {

	public:
		static bool canParse( ) {
			return AST_AtomicExpression.canParse;
		}

		static AST_Expression parse( ) {
			AST_Expression base;
			AST_P1ExpressionItem[ ] items;

			if ( AST_AtomicExpression.canParse )
				base = AST_AtomicExpression.parse( );
			else if ( AST_AutoExpression.canParse )
				base = AST_AutoExpression.parse( );
			else
				currentToken.reportsyntaxError( "expression (atomic)" );

			while ( true ) {
				if ( AST_ParentCommaExpression.canParse )
					items ~= AST_ParentCommaExpression.parse( );
				else if ( AST_P1_DotIdent.canParse )
					items ~= AST_P1_DotIdent.parse( );
				else
					break;
			}

			if ( items.length ) {
				AST_P1Expression result = new AST_P1Expression;
				result.base = base;
				result.items = items;

				return result;
			}
			else
				return base;
		}

	public:
		AST_Expression base;
		AST_P1ExpressionItem[ ] items;

	public:
		final override bool isP1Expression( ) {
			return true;
		}

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, DataScope scope_, bool errorOnInferrationFailure = true ) {
			const auto _gd = ErrorGuard( this );

			assert( items.length );

			// We're passing null as expected type because expected type applies only to the rightmost part of the expression
			Overloadset result = base.buildSemanticTree( inferredType, scope_, errorOnInferrationFailure );
			if ( !result )
				return result;

			foreach ( item; items )
				result = item.p1expressionItem_buildSemanticTree( result, scope_ );

			return result;
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( base, cast( AST_Node[ ] ) items );
		}

}

interface AST_P1ExpressionItem {

	public:
		Overloadset p1expressionItem_buildSemanticTree( Overloadset leftSide, DataScope scope_ );

}
