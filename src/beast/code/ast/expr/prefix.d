module beast.code.ast.expr.prefix;

import beast.code.ast.toolkit;
import beast.code.ast.expr.suffix;

final class AST_PrefixExpression : AST_Expression {
	alias LowerLevelExpression = AST_SuffixExpression;

public:
	enum Operator {
		emark,
	}

public:
	static bool canParse() {
		return LowerLevelExpression.canParse || currentToken == Token.Operator.exclamationMark;
	}

	static AST_Expression parse() {
		auto _gd = codeLocationGuard();

		if (currentToken.matchAndNext(Token.Operator.exclamationMark))
			return new AST_PrefixExpression(LowerLevelExpression.parse(), [Operator.emark], _gd.get());

		return LowerLevelExpression.parse();
	}

private:
	this(AST_Expression base, Operator[] operators, CodeLocation loc) {
		this.base = base;
		this.operators = operators;
		this.codeLocation = loc;
	}

public:
	AST_Expression base;
	Operator[] operators;

public:
	override Overloadset buildSemanticTree(Symbol_Type inferredType, bool errorOnInferrationFailure = true) {
		const auto __gd = ErrorGuard(codeLocation);

		DataEntity result = base.buildSemanticTree_singleInfer(inferredType, errorOnInferrationFailure);
		if (!result)
			return Overloadset();

		foreach (op; operators) {
			if (op == Operator.emark)
				result = result.expectResolveIdentifier(ID!"#opPrefix").resolveCall(this, true, coreEnum.operator.preNot);
			else
				assert(0);
		}

		return result.Overloadset;
	}

public:
	final override bool isPrefixExpression() {
		return true;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(base);
	}

}
