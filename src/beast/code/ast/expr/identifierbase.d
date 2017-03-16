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
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			const auto _gd = ErrorGuard( this );
			assert( currentScope );

			Overloadset result;

			if ( precedingColon ) {
				// :ident variant
				if ( inferredType is null ) {
					if ( errorOnInferrationFailure )
						berror( E.cannotInfer, "Cannot infer scope for identifier '%s' lookup".format( identifier.str ) );

					return Overloadset( );
				}

				result = inferredType.dataEntity.resolveIdentifier( identifier );

				if ( result.isEmpty ) {
					if ( errorOnInferrationFailure )
						berror( E.unknownIdentifier, "Cannot resolve identifier '%s' in scope '%s'".format( identifier.str, precedingColon ? inferredType.dataEntity.identificationString : currentScope.identificationString ) );

					return Overloadset( );
				}
			}
			else {
				result = currentScope.recursivelyResolveIdentifier( identifier );

				benforce( !result.isEmpty, E.unknownIdentifier, "Cannot resolve identifier '%s' in scope '%s'".format( identifier.str, precedingColon ? inferredType.dataEntity.identificationString : currentScope.identificationString ) );
			}

			return result;
		}

	public:
		/// If true, the identifier was 
		bool precedingColon;
		Identifier identifier;

}
