module beast.code.ast.expr.mult;

import beast.code.ast.toolkit;
import beast.code.ast.expr.new_;
import beast.code.ast.expr.binary;

final class AST_MultExpression : AST_Expression {
	alias LowerLevelExpression = AST_NewExpression;

public:
	static bool canParse() {
		return LowerLevelExpression.canParse;
	}

	static AST_Expression parse() {
		auto _gd = codeLocationGuard();

		AST_Expression base = LowerLevelExpression.parse();

		if (currentToken != Token.Operator.multiply && currentToken != Token.Operator.divide)
			return base;

		auto result = new AST_MultExpression;
		result.base = base;

		while (currentToken == Token.Operator.multiply || currentToken == Token.Operator.divide) {
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
	override Overloadset buildSemanticTree(Symbol_Type inferredType, bool ctime, bool errorOnInferrationFailure = true) {
		const auto __gd = ErrorGuard(codeLocation);

		DataEntity result = base.buildSemanticTree_singleInfer(inferredType, ctime, errorOnInferrationFailure);

		// If errorOnInferrationFailure is false then result might be null (inferration failure)
		if (!result)
			return Overloadset();

		DataEntity opArg;

		auto opr = &coreEnum.operator;

		foreach (item; items) {
			switch (item.op) {

			case Token.Operator.multiply:
				opArg = opr.binMult.dataEntity;
				break;

			case Token.Operator.divide:
				opArg = opr.binDiv.dataEntity;
				break;

			default:
				assert(0);

			}

			result = resolveBinaryOperation(this, result, item.expr, opArg, item.op, ctime);
		}

		return result.Overloadset;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(base, items.map!(x => x.expr));
	}

}
