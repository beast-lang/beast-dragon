module beast.code.ast.expr.sum;

import beast.code.ast.toolkit;
import beast.code.ast.expr.mult;
import beast.code.ast.expr.binary;

final class AST_SumExpression : AST_Expression {
	alias LowerLevelExpression = AST_MultExpression;

public:
	static bool canParse() {
		return LowerLevelExpression.canParse;
	}

	static AST_Expression parse() {
		auto _gd = codeLocationGuard();

		AST_Expression base = LowerLevelExpression.parse();

		if (currentToken != Token.Operator.plus && currentToken != Token.Operator.minus)
			return base;

		auto result = new AST_SumExpression;
		result.base = base;

		while (currentToken == Token.Operator.plus || currentToken == Token.Operator.minus) {
			Item item;
			item.op = currentToken.operator;

			getNextToken();
			item.expr = LowerLevelExpression.parse();

			result.items ~= item;
		}

		result.codeLocation = _gd.get();
		return result;
	}

public:
	AST_Expression base;
	Item[] items;

public:
	struct Item {
		Token.Operator op;
		AST_Expression expr;
	}

public:
	override Overloadset buildSemanticTree(Symbol_Type inferredType, bool errorOnInferrationFailure = true) {
		const auto __gd = ErrorGuard(codeLocation);

		DataEntity result = base.buildSemanticTree_singleInfer(inferredType, errorOnInferrationFailure);

		// If errorOnInferrationFailure is false then result might be null (inferration failure)
		if (!result)
			return Overloadset();

		DataEntity opArg;

		auto opr = &coreEnum.operator;

		foreach (item; items) {
			switch (item.op) {

			case Token.Operator.plus:
				opArg = opr.binPlus.dataEntity;
				break;

			case Token.Operator.minus:
				opArg = opr.binMinus.dataEntity;
				break;

			default:
				assert(0);

			}

			result = resolveBinaryOperation(this, result, item.expr, opArg, item.op);
		}

		return result.Overloadset;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(base, items.map!(x => x.expr));
	}

}
