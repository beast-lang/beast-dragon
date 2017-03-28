module beast.code.ast.expr.unary;

import beast.code.ast.toolkit;
import beast.code.ast.expr.p1;

final class AST_UnaryExpression : AST_Expression {
	alias LowerLevelExpression = AST_P1Expression;

	public:
		enum Operator {
			// PREFIX OPERATORS
			preNot,

			// SUFFIX OPERATORS
			questionMark,
			suffNot,
		}

	public:
		static bool canParse( ) {
			return LowerLevelExpression.canParse || currentToken == Token.Operator.exclamationMark;
		}

		static AST_Expression parse( ) {
			auto _gd = codeLocationGuard( );

			if ( currentToken.matchAndNext( Token.Operator.exclamationMark ) )
				return new AST_UnaryExpression( LowerLevelExpression.parse( ), [ Operator.preNot ], _gd.get( ) );

			AST_Expression base = LowerLevelExpression.parse( );

			if ( currentToken != Token.Type.operator )
				return base;

			switch ( currentToken.operator ) {

			case Token.Operator.questionMark:
			case Token.Operator.exclamationMark: {
					Operator[ ] ops;

					while ( true ) {
						if ( currentToken.matchAndNext( Token.Operator.exclamationMark ) )
							ops ~= Operator.suffNot;
						else if ( currentToken.matchAndNext( Token.Operator.questionMark ) )
							ops ~= Operator.questionMark;
						else
							break;
					}

					return new AST_UnaryExpression( base, ops, _gd.get( ) );
				}

			default:
				return base;

			}
		}

	private:
		this( AST_Expression base, Operator[ ] operators, CodeLocation loc ) {
			this.base = base;
			this.operators = operators;
			this.codeLocation = loc;
		}

	public:
		AST_Expression base;
		Operator[ ] operators;

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			const auto __gd = ErrorGuard( codeLocation );

			DataEntity result = base.buildSemanticTree_singleInfer( inferredType, errorOnInferrationFailure );
			if ( !result )
				return Overloadset( );

			foreach ( op; operators ) {
				final switch ( op ) {

					// PREFIX OPERATORS
				case Operator.preNot:
					result = result.resolveIdentifier( ID!"#operator" ).resolveCall( this, true, coreLibrary.enum_.operator.preNot );
					break;

					// SUFFIX OPERATORS
				case Operator.questionMark:
					result = result.resolveIdentifier( ID!"#operator" ).resolveCall( this, true, coreLibrary.enum_.operator.suffRef );
					break;

				case Operator.suffNot:
					result = result.resolveIdentifier( ID!"#operator" ).resolveCall( this, true, coreLibrary.enum_.operator.suffNot );
					break;

				}
			}

			return result.Overloadset;
		}

	public:
		final override bool isUnaryExpression( ) {
			return true;
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( base );
		}

}
