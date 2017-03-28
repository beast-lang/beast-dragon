module beast.code.ast.expr.logic;

import beast.code.ast.toolkit;
import beast.code.ast.expr.sum;

final class AST_LogicExpression : AST_Expression {
	alias LowerLevelExpression = AST_SumExpression;

	public:
		static bool canParse( ) {
			return LowerLevelExpression.canParse;
		}

		static AST_Expression parse( ) {
			auto _gd = codeLocationGuard( );

			AST_Expression base = LowerLevelExpression.parse( );

			if ( currentToken != Token.Operator.logOr && currentToken != Token.Operator.logAnd )
				return base;

			AST_LogicExpression result = new AST_LogicExpression;
			result.op = currentToken.operator;
			result.base = base;

			while ( currentToken == Token.Operator.logOr || currentToken == Token.Operator.logAnd ) {
				benforce( currentToken == result.op, E.invalidOpCombination, "You cannot mix && and || operators, use parentheses", ( err ) { err.codeLocation = currentToken.codeLocation; } );
				getNextToken( );

				result.items ~= LowerLevelExpression.parse( );
			}

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		AST_Expression base;
		AST_Expression[ ] items;
		Token.Operator op;

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			const auto __gd = ErrorGuard( codeLocation );

			DataEntity result = base.buildSemanticTree_singleInfer( inferredType, errorOnInferrationFailure );

			// If errorOnInferrationFailure is false then result might be null (inferration failure)
			if ( !result )
				return Overloadset( );

			DataEntity opArg = ( op == Token.Operator.logOr ) ? coreLibrary.enum_.operator.binOr.dataEntity : coreLibrary.enum_.operator.binAnd.dataEntity;
			DataEntity opRightArg = ( op == Token.Operator.logOr ) ? coreLibrary.enum_.operator.binOrR.dataEntity : coreLibrary.enum_.operator.binAndR.dataEntity;

			foreach ( item; items ) {
				if ( auto op = result.tryResolveIdentifier( ID!"#operator" ).resolveCall( this, false, opArg, item ) ) {
					result = op;
					continue;
				}

				// If looking for left.#operator( xx, right ) failed, we build right side and try right.#operator( xxR, left )
				DataEntity entity = item.buildSemanticTree( null, false ).single;

				// If errorOnInferrationFailure is false then entity might be null (inferration failure)
				if ( !entity )
					return Overloadset( );

				if ( auto op = entity.tryResolveIdentifier( ID!"#operator" ).resolveCall( this, false, opRightArg, item ) ) {
					result = op;
					continue;
				}

				berror( E.cannotResolve, "Cannot resolve %s %s %s".format( result.identificationString, Token.operatorStr[ op ], entity.identificationString ) );
			}

			return result.Overloadset;
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( base, items );
		}

}
