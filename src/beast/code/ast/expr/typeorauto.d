module beast.code.ast.expr.typeorauto;

import beast.code.ast.toolkit;
import beast.code.ast.expr.identifierbase;

final class AST_TypeOrAutoExpression : AST_Expression {

public:
	static bool canParse( ) {
		return AST_P1Expression.canParse || currentToken == Token.Keyword.auto_;
	}

	static AST_TypeOrAutoExpression parse( ) {
		auto _gd = codeLocationGuard( );
		AST_TypeOrAutoExpression result = new AST_TypeOrAutoExpression;

		if ( AST_P1Expression.canParse )
			result.expr = AST_P1Expression.parse( );
		else {
			currentToken.expect( Token.Keyword.auto_, "type or 'auto'" );
			result.isAuto = true;

			// TODO: auto mut etc.
		}

		result.codeLocation = _gd.get( );
		return result;
	}

public:
	override DataEntity buildSemanticTree( Symbol_Type expectedType, DataScope scope_, bool errorOnFailure = true ) {
		assert( !isAuto );
		return expr.buildSemanticTree( expectedType, scope_, errorOnFailure );
	}

public:
	AST_Expression expr;
	/// If true, the expression was 'auto'
	bool isAuto;
	bool isAutoMut;
	bool isAutoRef;
	bool isAutoRefMut;

protected:
	override InputRange!AST_Node _subnodes( ) {
		return nodeRange( expr );
	}

}
