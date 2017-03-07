module beast.code.ast.expr.logic;

import beast.code.ast.toolkit;
import beast.code.ast.expr.p1;

final class AST_LogicExpression : AST_Expression {
	alias LowerLevelExpression = AST_P1Expression;

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
				currentToken.expectAndNext( result.op, "You cannot mix && and || operators, use parentheses" );
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
		override Overloadset buildSemanticTree( Symbol_Type inferredType, DataScope scope_, bool errorOnInferrationFailure = true ) {
			const auto _gd = ErrorGuard( this );

			DataEntity result = base.buildSemanticTree( inferredType, scope_, true ).single( );
			if ( !result )
				return Overloadset( );

			// TODO: also and operator
			DataEntity opArg = coreLibrary.constants.operator_or.dataEntity;
			DataEntity opRightArg = coreLibrary.constants.operator_orRight.dataEntity;

			foreach ( item; items ) {
				if ( auto op = result.resolveIdentifier( ID!"#operator", scope_ ).CallMatchSet( scope_, this, false ).argument( opArg ).argument( item ).finish( ) ) {
					result = op;
					continue;
				}

				DataEntity entity = item.buildSemanticTree( null, scope_, false ).single;
				if ( auto op = entity.resolveIdentifier( ID!"#operator", scope_ ).CallMatchSet( scope_, this, false ).argument( opRightArg ).argument( item ).finish( ) ) {
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
