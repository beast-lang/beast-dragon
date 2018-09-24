module beast.code.ast.expr.logic;

import beast.code.ast.toolkit;
import beast.code.ast.expr.cmp;
import beast.code.ast.expr.binary;

final class AST_LogicExpression : AST_Expression {
	alias LowerLevelExpression = AST_CmpExpression;

public:
	static bool canParse() {
		return LowerLevelExpression.canParse;
	}

	static AST_Expression parse() {
		auto _gd = codeLocationGuard();

		AST_Expression base = LowerLevelExpression.parse();

		if (currentToken != Token.Operator.logOr && currentToken != Token.Operator.logAnd)
			return base;

		auto result = new AST_LogicExpression;
		result.op = currentToken.operator;
		result.base = base;

		while (currentToken == Token.Operator.logOr || currentToken == Token.Operator.logAnd) {
			benforce(currentToken == result.op, E.invalidOpCombination, "You cannot mix && and || operators, use parentheses", (err) { err.codeLocation = currentToken.codeLocation; });
			getNextToken();

			result.items ~= LowerLevelExpression.parse();
		}

		result.codeLocation = _gd.get();
		return result;
	}

public:
	AST_Expression base;
	AST_Expression[] items;
	Token.Operator op;

public:
	override Overloadset buildSemanticTree(Symbol_Type inferredType, bool ctime, bool errorOnInferrationFailure = true) {
		const auto __gd = ErrorGuard(codeLocation);

		DataEntity result = base.buildSemanticTree_singleInfer(inferredType, ctime, errorOnInferrationFailure);

		// If errorOnInferrationFailure is false then result might be null (inferration failure)
		if (!result)
			return Overloadset();

		DataEntity opArg = (op == Token.Operator.logOr) ? coreEnum.operator.binOr.dataEntity : coreEnum.operator.binAnd.dataEntity;

		foreach (item; items)
			result = resolveBinaryOperation(this, result, item, opArg, op, ctime);

		return result.Overloadset;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(base, items);
	}

}
