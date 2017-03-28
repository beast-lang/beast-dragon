module beast.code.ast.expr.sum;

import beast.code.ast.toolkit;
import beast.code.ast.expr.unary;

final class AST_SumExpression : AST_Expression {
	alias LowerLevelExpression = AST_UnaryExpression;

	public:
		static bool canParse( ) {
			return LowerLevelExpression.canParse;
		}

		static AST_Expression parse( ) {
			auto _gd = codeLocationGuard( );

			AST_Expression base = LowerLevelExpression.parse( );

			if ( currentToken != Token.Operator.plus && currentToken != Token.Operator.minus )
				return base;

			auto result = new AST_SumExpression;
			result.base = base;

			while ( currentToken == Token.Operator.plus || currentToken == Token.Operator.minus ) {
				Item item;
				item.op = currentToken.operator;

				getNextToken( );
				item.expr = LowerLevelExpression.parse( );

				result.items ~= item;
			}

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		AST_Expression base;
		Item[ ] items;

	public:
		struct Item {
			Token.Operator op;
			AST_Expression expr;
		}

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			const auto __gd = ErrorGuard( codeLocation );

			DataEntity result = base.buildSemanticTree_singleInfer( inferredType, errorOnInferrationFailure );

			// If errorOnInferrationFailure is false then result might be null (inferration failure)
			if ( !result )
				return Overloadset( );

			DataEntity opArg;
			DataEntity opArgR;

			auto opr = &coreLibrary.enum_.operator;

			foreach ( item; items ) {
				switch ( item.op ) {

				case Token.Operator.plus:
					opArg = opr.binPlus.dataEntity;
					opArgR = opr.binPlusR.dataEntity;
					break;

				case Token.Operator.minus:
					opArg = opr.binMinus.dataEntity;
					opArgR = opr.binMinusR.dataEntity;
					break;

				default:
					assert( 0 );

				}

				// First we try left.#operator( op, right )
				if ( auto op = result.tryResolveIdentifier( ID!"#operator" ).resolveCall( this, false, opArg, item.expr ) ) {
					result = op;
					continue;
				}

				// If looking for left.#operator( xx, right ) failed, we build right side and try right.#operator( xxR, left )
				DataEntity entity = item.expr.buildSemanticTree( null, false ).single;

				// If errorOnInferrationFailure is false then entity might be null (inferration failure)
				if ( !entity )
					return Overloadset( );

				// Then we try right.#opreator( opR, left )
				if ( auto op = entity.tryResolveIdentifier( ID!"#operator" ).resolveCall( this, false, opArgR, item.expr ) ) {
					result = op;
					continue;
				}

				berror( E.cannotResolve, "Cannot resolve %s %s %s".format( result.identificationString, Token.operatorStr[ item.op ], entity.identificationString ) );
			}

			return result.Overloadset;
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( base, items.map!( x => x.expr ) );
		}

}
