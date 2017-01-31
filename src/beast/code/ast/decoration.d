module beast.code.ast.decoration;

import beast.code.ast.toolkit;

/// '@' identifier [ ParentCommaExpr ]
final class AST_Decoration : ASTNode {

public:
	static bool canParse( ) {
		return currentToken == Token.Special.at;
	}

	static AST_Decoration parse( ) {
		auto result = new AST_Decoration;

		currentToken.expect( Token.Special.at );

		getNextToken();
		result.identifier = AST_Identifier.parse( );

		return result;
	}

public:
	AST_Identifier identifier;

public:
	override ASTNode[ ] subnodes( ) {
		return [ identifier ];
	}

}
