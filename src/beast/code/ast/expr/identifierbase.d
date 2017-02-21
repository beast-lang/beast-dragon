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

		getNextToken( );

		result.codeLocation = clg.get( );
		return result;
	}

public:
	override DataEntity buildTree( Symbol_Type expectedType, DataScope scope_ ) {
		Overloadset result;

		if ( precedingColon ) {
			// :ident variant
			benforce( expectedType !is null, E.cannotInfer, "Cannot infer scope for identifier '%s' lookup".format( identifier.str ) );
			result = expectedType.data.resolveIdentifierRecursively( identifier );
		}
		else
			result = scope_.resolveIdentifierRecursively( identifier );

		benforce( cast( bool ) result, E.unknownIdentifier, "Cannot resolve identifier '%s' in scope '%s'".format( identifier.str, precedingColon ? expectedType.data.identificationString : scope_.identificationString ) );
		return result.single_expectType( expectedType );
	}

public:
	/// If true, the identifier was 
	bool precedingColon;
	Identifier identifier;

}
