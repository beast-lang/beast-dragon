module beast.code.ast.expr.identifierbase;

import beast.code.ast.toolkit;
import beast.code.ast.expr.atomic;

/// "ident" or ":ident" on the beginning of P1 expression
final class AST_IdentifierBaseExpression : AST_AtomicExpression {

public:
	static bool canParse( ) {
		return currentToken == Token.Type.identifier || currentToken == Token.Special.colon;
	}

	static AST_Expression parse( ) {
		auto clg = codeLocationGuard( );
		AST_IdentifierBaseExpression result = new AST_IdentifierBaseExpression( );

		if ( currentToken == Token.Special.colon ) {
			result.precedingColon = true;
			getNextToken( );
		}

		currentToken.expect( Token.Type.identifier );
		result.identifier = currentToken.identifier;

		result.codeLocation = clg.get( );
		return result;
	}

public:
/// If true, the identifier was 
	bool precedingColon;
	Identifier identifier;

}
