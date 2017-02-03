module beast.code.ast.identifier;

import beast.code.ast.toolkit;
import beast.code.ast.expr.expression;

/// Identifier wrapped in the AST node because of codeLocation and relatedSymbol
final class AST_Identifier : AST_Expression {

public:
	static bool canParse( ) {
		return currentToken == Token.Type.identifier;
	}

	static AST_Identifier parse( ) {
		auto result = new AST_Identifier;

		currentToken.expect( Token.Type.identifier );
		result.identifier = currentToken.identifier;
		result.codeLocation = currentToken.codeLocation;

		getNextToken( );

		return result;
	}

public:
	Identifier identifier;
	alias identifier this;

}
