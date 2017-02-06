module beast.code.ast.decoration;

import beast.code.ast.toolkit;

/// '@' identifier [ ParentCommaExpr ]
final class AST_Decoration : AST_Node {

public:
	static bool canParse( ) {
		return currentToken == Token.Special.at;
	}

	static AST_Decoration parse( ) {
		auto result = new AST_Decoration;

		currentToken.expect( Token.Special.at );

		getNextToken( ).expect( Token.Type.identifier, "decorator identifier" );
		result.identifier = AST_Identifier.parse( );

		return result;
	}

public:
	AST_Identifier identifier;

protected:
	override InputRange!AST_Node _subnodes( ) {
		return nodeRange( identifier );
	}

}
