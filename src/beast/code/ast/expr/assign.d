module beast.code.ast.expr.assign;

import beast.code.ast.toolkit;
import beast.code.ast.expr.logic;
import beast.code.symbol.symbol;

final class AST_AssignExpression : AST_Expression {
	alias LowerLevelExpression = AST_LogicExpression;

public:
	static bool canParse() {
		return LowerLevelExpression.canParse;
	}

	static AST_Expression parse() {
		auto _gd = codeLocationGuard();

		AST_Expression base = LowerLevelExpression.parse();

		if (currentToken != Token.Type.operator)
			return base;

		auto op = currentToken.operator;
		getNextToken();

		switch (op) {

		case Token.Operator.assign:
			return new AST_AssignExpression(ID!"#assign", null, base, LowerLevelExpression.parse(), _gd.get());

		case Token.Operator.colonAssign:
			return new AST_AssignExpression(ID!"#refAssign", null, base, LowerLevelExpression.parse(), _gd.get());

		default:
			return base;

		}
	}

private:
	this(Identifier id, Symbol operatorConstArg, AST_Expression left, AST_Expression right, CodeLocation loc) {
		this.operatorConstArg = operatorConstArg ? operatorConstArg.dataEntity : null;
		this.left = left;
		this.right = right;
		this.codeLocation = loc;
		this.id = id;
	}

public:
	AST_Expression left, right;
	DataEntity operatorConstArg;
	Identifier id;

public:
	override Overloadset buildSemanticTree(Symbol_Type inferredType, bool errorOnInferrationFailure = true) {
		const auto __gd = ErrorGuard(codeLocation);

		auto match = left.buildSemanticTree_single().expectResolveIdentifier(id).CallMatchSet(this, true);

		if (operatorConstArg)
			match.arg(operatorConstArg);

		return match.arg(right).finish().Overloadset;
	}

public:
	final override bool isPrefixExpression() {
		return true;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(left, right);
	}

}
