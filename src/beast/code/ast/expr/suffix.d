module beast.code.ast.expr.suffix;

import beast.code.ast.toolkit;
import beast.code.ast.expr.atomic;
import beast.code.ast.expr.auto_;
import beast.code.ast.expr.parentcomma;
import beast.code.ast.expr.suffix_dotident;
import beast.code.ast.expr.suffix_ops;
import std.typecons : Tuple, tuple;

final class AST_SuffixExpression : AST_Expression {

	public:
		static bool canParse( ) {
			return AST_AtomicExpression.canParse || AST_AutoExpression.canParse;
		}

		static AST_Expression parse( ) {
			auto _gd = codeLocationGuard();

			AST_Expression base;
			AST_SuffixExpressionItem[ ] items;

			if ( AST_AtomicExpression.canParse )
				base = AST_AtomicExpression.parse( );
			else if ( AST_AutoExpression.canParse )
				base = AST_AutoExpression.parse( );
			else
				currentToken.reportSyntaxError( "expression (atomic)" );

			while ( true ) {
				if ( AST_ParentCommaExpression.canParse )
					items ~= AST_ParentCommaExpression.parse( );
				else if ( AST_Suffix_DotIdent.canParse )
					items ~= AST_Suffix_DotIdent.parse( );
				else if ( AST_Suffix_Operators.canParse )
					items ~= AST_Suffix_Operators.parse( );
				else
					break;
			}

			if ( items.length ) {
				AST_SuffixExpression result = new AST_SuffixExpression;
				result.base = base;
				result.items = items;
				result.codeLocation = _gd.get();

				return result;
			}
			else
				return base;
		}

	public:
		AST_Expression base;
		AST_SuffixExpressionItem[ ] items;

	public:
		final override bool isPrefixExpression( ) {
			return true;
		}

		final override Tuple!( AST_Expression, AST_ParentCommaExpression ) asNewRightExpression( ) {
			if ( auto right = items[ $ - 1 ].isParentCommaExpression ) {
				AST_Expression expr;

				if ( items.length > 1 ) {
					auto e = new AST_SuffixExpression;
					e.codeLocation = CodeLocation( base.codeLocation.source, base.codeLocation.startPos, right.codeLocation.startPos - base.codeLocation.startPos );
					e.base = base;
					e.items = items[ 0 .. $ - 1 ];
					expr = e;
				}
				else
					expr = base;

				return tuple( expr, right );
			}

			return super.asNewRightExpression( );
		}

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			const auto __gd = ErrorGuard( codeLocation );

			assert( items.length );

			// We're passing null as expected type because expected type applies only to the rightmost part of the expression
			Overloadset result = base.buildSemanticTree( inferredType, errorOnInferrationFailure );

			// If errorOnInferrationFailure is false then entity might be null (inferration failure)
			if ( !result )
				return result;

			foreach ( item; items )
				result = item.p1expressionItem_buildSemanticTree( result );

			return result;
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( base, cast( AST_Node[ ] ) items );
		}

}

interface AST_SuffixExpressionItem {

	public:
		abstract Overloadset p1expressionItem_buildSemanticTree( Overloadset leftSide );

		abstract AST_ParentCommaExpression isParentCommaExpression( );

}
