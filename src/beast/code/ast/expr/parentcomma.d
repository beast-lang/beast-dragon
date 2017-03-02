module beast.code.ast.expr.parentcomma;

import beast.code.ast.toolkit;

/// Parameter list used in declarations
final class AST_ParentCommaExpression : AST_Expression {

public:
	static bool canParse( ) {
		return currentToken == Token.Special.lParent;
	}

	static AST_ParentCommaExpression parse( ) {
		auto _gd = codeLocationGuard( );
		auto result = new AST_ParentCommaExpression( );

		currentToken.expectAndNext( Token.Special.lParent );

		if ( AST_Expression.canParse ) {
			result.items ~= AST_Expression.parse( );

			while ( currentToken.matchAndNext( Token.Special.comma ) )
				result.items ~= AST_Expression.parse( );

			currentToken.expectAndNext( Token.Special.rParent, "',' or ')' after expression" );
		}
		else
			currentToken.expectAndNext( Token.Special.rParent, "expression or ')'" );

		result.codeLocation = _gd.get( );
		return result;
	}

public:
	AST_Expression[ ] items;

public:
	override DataEntity buildSemanticTree( Symbol_Type expectedType, DataScope scope_, bool errorOnFailure = true ) {
		// Maybe replace with void?
		benforce( items.length > 0, E.syntaxError, "Empty parentheses" );

		foreach ( e; items[ 0 .. $ - 1 ] )
			e.buildSemanticTree( null, scope_, errorOnFailure );

		return items[ $ - 1 ].buildSemanticTree( expectedType, scope_, errorOnFailure );
	}

protected:
	override InputRange!AST_Node _subnodes( ) {
		return nodeRange( items );
	}

}