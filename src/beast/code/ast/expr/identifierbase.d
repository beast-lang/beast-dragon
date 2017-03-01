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

		if ( currentToken.matchAndNext( Token.Special.colon ) )
			result.precedingColon = true;

		currentToken.expect( Token.Type.identifier );
		result.identifier = currentToken.identifier;
		getNextToken( );

		result.codeLocation = clg.get( );
		return result;
	}

public:
	override DataEntity buildSemanticTree( Symbol_Type expectedType, DataScope scope_, bool errorOnFailure = true ) {
		const auto _gd = ErrorGuard( this );
		
		Overloadset result;

		if ( precedingColon ) {
			// :ident variant
			if ( expectedType is null ) {
				if ( errorOnFailure )
					berror( E.cannotInfer, "Cannot infer scope for identifier '%s' lookup".format( identifier.str ) );

				return null;
			}
			
			result = expectedType.dataEntity.resolveIdentifier( identifier, scope_ );
		}
		else
			result = scope_.recursivelyResolveIdentifier( identifier, scope_ );

		if ( !result ) {
			if ( errorOnFailure )
				berror( E.unknownIdentifier, "Cannot resolve identifier '%s' in scope '%s'".format( identifier.str, precedingColon ? expectedType.dataEntity.identificationString : scope_.identificationString ) );

			return null;
		}

		return result.single_expectType( expectedType );
	}

public:
	/// If true, the identifier was 
	bool precedingColon;
	Identifier identifier;

}
