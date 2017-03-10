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
		override Overloadset buildSemanticTree( Symbol_Type inferredType, DataScope scope_, bool errorOnInferrationFailure = true ) {
			const auto _gd = ErrorGuard( this );

			DataEntity result = base.buildSemanticTree_single( inferredType, scope_, true );
			if ( !result )
				return Overloadset( );

			// TODO: also and operator
			DataEntity opArg = coreLibrary.enum_.operator.binOr.dataEntity;
			DataEntity opRightArg = coreLibrary.enum_.operator.binOrR.dataEntity;

			foreach ( item; items ) {
				if ( auto op = result.resolveIdentifier( ID!"#operator", scope_ ).resolveCall( scope_, this, false, opArg, item ) ) {
					result = op;
					continue;
				}

				DataEntity entity = item.buildSemanticTree( null, scope_, false ).single;
				if ( auto op = entity.resolveIdentifier( ID!"#operator", scope_ ).resolveCall( scope_, this, false, opRightArg, item ) ) {
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
