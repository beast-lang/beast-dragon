module beast.code.ast.expr.assign;

import beast.code.ast.toolkit;
import beast.code.ast.expr.logic;
import beast.code.data.symbol;

final class AST_AssignExpression : AST_Expression {
	alias LowerLevelExpression = AST_LogicExpression;

	public:
		static bool canParse( ) {
			return LowerLevelExpression.canParse;
		}

		static AST_Expression parse( ) {
			auto _gd = codeLocationGuard( );

			AST_Expression base = LowerLevelExpression.parse( );

			if ( currentToken != Token.Type.operator )
				return base;

			auto op = currentToken.operator;
			getNextToken( );

			switch ( op ) {

			case Token.Operator.assign:
				return new AST_AssignExpression( coreLibrary.enum_.operator.assign, base, LowerLevelExpression.parse( ), _gd.get( ) );

			case Token.Operator.colonAssign:
				return new AST_AssignExpression( coreLibrary.enum_.operator.refAssign, base, LowerLevelExpression.parse( ), _gd.get( ) );

			default:
				return base;

			}
		}

	private:
		this( Symbol operatorConstArg, AST_Expression left, AST_Expression right, CodeLocation loc ) {
			this.operatorConstArg = operatorConstArg.dataEntity;
			this.left = left;
			this.right = right;
			this.codeLocation = loc;
		}

	public:
		AST_Expression left, right;
		DataEntity operatorConstArg;

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			const auto __gd = ErrorGuard( codeLocation );
			
			return left.buildSemanticTree_single( ).resolveIdentifier( ID!"#operator" ).resolveCall( this, true, operatorConstArg, right ).Overloadset;
		}

	public:
		final override bool isUnaryExpression( ) {
			return true;
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( left, right );
		}

}
