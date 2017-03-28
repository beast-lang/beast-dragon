module beast.code.ast.expr.literal;

import beast.code.ast.toolkit;
import beast.code.ast.expr.atomic;

/// "ident" or ":ident" on the beginning of P1 expression
final class AST_LiteralExpression : AST_AtomicExpression {

	public:
		pragma( inline ) static bool canParse( ) {
			return currentToken == Token.Type.literal;
		}

		static AST_Expression parse( ) {
			auto clg = codeLocationGuard( );

			auto result = new AST_LiteralExpression( );

			currentToken.expect( Token.Type.literal );
			result.data = currentToken.literal;

			getNextToken( );

			result.codeLocation = clg.get( );
			return result;
		}

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			return data.Overloadset;
		}

	public:
		DataEntity data;

}
