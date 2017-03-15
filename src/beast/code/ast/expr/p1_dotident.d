module beast.code.ast.expr.p1_dotident;

import beast.code.ast.toolkit;
import beast.code.ast.expr.p1;
import beast.code.ast.identifier;

/// expr.ident
final class AST_P1_DotIdent : AST_Node, AST_P1ExpressionItem {

	public:
		static bool canParse( ) {
			return currentToken == Token.Special.dot;
		}

		static AST_P1_DotIdent parse( ) {
			auto _gd = codeLocationGuard( );
			auto result = new AST_P1_DotIdent( );

			currentToken.expectAndNext( Token.Special.dot );

			result.identifier = AST_Identifier.parse( );

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		AST_Identifier identifier;

	public:
		override Overloadset p1expressionItem_buildSemanticTree( Overloadset leftSide, DataScope scope_ ) {
			const auto _gd = ErrorGuard( this );
			return leftSide.single.expectResolveIdentifier( identifier, scope_ );
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( identifier );
		}

}
