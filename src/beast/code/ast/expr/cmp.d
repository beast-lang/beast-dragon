module beast.code.ast.expr.cmp;

import beast.code.ast.toolkit;
import beast.code.ast.expr.sum;
import beast.code.ast.expr.binary;
import std.range : chain;
import beast.code.semantic.util.cached;
import beast.code.semantic.var.btspconst;

final class AST_CmpExpression : AST_Expression {
	alias LowerLevelExpression = AST_SumExpression;

public:
	static bool canParse() {
		return LowerLevelExpression.canParse;
	}

	static AST_Expression parse() {
		auto _gd = codeLocationGuard();

		AST_Expression base = LowerLevelExpression.parse();

		if (!isCmpOperator(currentToken))
			return base;

		auto result = new AST_CmpExpression;
		result.base = base;

		CmpOperatorGroups groups = cmpOperatorGroups(currentToken.operator);
		while (isCmpOperator(currentToken)) {
			Item item;
			item.op = currentToken.operator;

			groups &= cmpOperatorGroups(item.op);
			benforce(groups != 0 || result.items.length == 0, E.invalidOpCombination, //
					"Cannot combine comparison operators %s".format(chain(result.items.map!(x => x.op), [item.op]).map!(x => "'%s'".format(Token.operatorStr[cast(int) x])).joiner(", ")), //
					(err) { err.codeLocation = _gd.get(); });

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

		DataEntity baseOperand = base.buildSemanticTree_singleInfer(inferredType, ctime, errorOnInferrationFailure);
		if (baseOperand.dataType.isCtime)
			baseOperand = baseOperand.ctExec_asDataEntity;

		DataEntity leftOperand = baseOperand;
		DataEntity result = null;

		// If errorOnInferrationFailure is false then result might be null (inferration failure)
		if (!baseOperand)
			return Overloadset();

		auto binAnd = coreEnum.operator.binAnd.dataEntity;

		foreach (item; items[0 .. $ - 1]) {
			CachedDataEntity rightExpr = item.expr.buildSemanticTree_single(ctime).CachedDataEntity;
			DataEntity data = resolveBinaryOperation(item.expr, leftOperand, rightExpr.definition, cmpOperatorEnumConst(item.op).dataEntity, item.op, ctime);

			if (result)
				result = resolveBinaryOperation(item.expr, result, data, binAnd, Token.Operator.logAnd, ctime);
			else
				result = data;

			leftOperand = rightExpr.reference;
		}

		// We don't need to save last operand to a variable
		{
			auto item = items[$ - 1];

			DataEntity rightExpr = item.expr.buildSemanticTree_single(ctime);
			auto cmpResult = resolveBinaryOperation(item.expr, leftOperand, rightExpr, cmpOperatorEnumConst(item.op).dataEntity, item.op, ctime);

			if (result)
				result = resolveBinaryOperation(item.expr, result, cmpResult, binAnd, Token.Operator.logAnd, ctime);
			else
				result = cmpResult;
		}

		return result.Overloadset;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(base, items.map!(x => x.expr));
	}

protected:
	pragma(inline) static bool isCmpOperator(Token token) {
		return token == Token.Operator.less || token == Token.Operator.lessEquals //
		 || token == Token.Operator.equals || token == Token.Operator.notEquals //
		 || token == Token.Operator.greater || token == Token.Operator.greaterEquals;
	}

	pragma(inline) static CmpOperatorGroups cmpOperatorGroups(Token.Operator op) {
		switch (op) {

		case Token.Operator.equals:
			return CmpOperatorGroups.ascending | CmpOperatorGroups.descending;

		case Token.Operator.notEquals:
			return CmpOperatorGroups.none;

		case Token.Operator.less:
		case Token.Operator.lessEquals:
			return CmpOperatorGroups.ascending;

		case Token.Operator.greater:
		case Token.Operator.greaterEquals:
			return CmpOperatorGroups.descending;

		default:
			assert(0);

		}
	}

	pragma(inline) static Symbol_BootstrapConstant cmpOperatorEnumConst(Token.Operator op) {
		switch (op) {

		case Token.Operator.equals:
			return coreEnum.operator.binEq;

		case Token.Operator.notEquals:
			return coreEnum.operator.binNeq;

		case Token.Operator.less:
			return coreEnum.operator.binLt;

		case Token.Operator.lessEquals:
			return coreEnum.operator.binLte;

		case Token.Operator.greater:
			return coreEnum.operator.binGt;

		case Token.Operator.greaterEquals:
			return coreEnum.operator.binGte;

		default:
			assert(0);

		}
	}

protected:
	enum CmpOperatorGroups {
		none = 0,
		ascending = 1, // < <= ==
		descending = ascending << 1 // > >= ==
	}

}
