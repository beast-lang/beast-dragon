module beast.code.ast.module_;

import beast.code.ast.toolkit;

final class AST_Module : ASTNode {

public:
	static AST_Module parse( ) {
		auto clg = codeLocationGuard( );
		auto result = new AST_Module;

		// module a.b.c;
		{
			currentToken.expect( Token.Keyword.module_ );
			getNextToken( );

			result.identifier = ExtendedIdentifier.parse( );

			currentToken.expect( Token.Special.semicolon );
		}

		result.codeLocation = clg.get( );
		return result;
	}

public:
	ExtendedIdentifier identifier;

}
