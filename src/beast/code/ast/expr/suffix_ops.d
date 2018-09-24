module beast.code.ast.expr.suffix_ops;

import beast.code.ast.toolkit;
import beast.code.ast.expr.suffix;
import beast.code.ast.identifier;
import beast.code.ast.expr.parentcomma;

/// expr.ident
final class AST_Suffix_Operators : AST_Node, AST_SuffixExpressionItem {

public:
	enum Operator {
		qmark,
		emark,
	}

public:
	static bool canParse() {
		return  //
		currentToken == Token.Operator.questionMark //
		 || currentToken == Token.Operator.exclamationMark;
	}

	static AST_SuffixExpressionItem parse() {
		auto _gd = codeLocationGuard();
		auto result = new AST_Suffix_Operators();

		assert(canParse);

		while (true) {
			if (currentToken.matchAndNext(Token.Operator.questionMark))
				result.ops ~= Operator.qmark;
			else if (currentToken.matchAndNext(Token.Operator.exclamationMark))
				result.ops ~= Operator.emark;
			else
				break;
		}

		result.codeLocation = _gd.get();
		return result;
	}

public:
	Operator[] ops;

public:
	override Overloadset p1expressionItem_buildSemanticTree(Overloadset leftSide, bool ctime) {
		const auto __gd = ErrorGuard(codeLocation);

		DataEntity result = leftSide.single;

		foreach (op; ops) {
			DataEntity suffXX;

			if (op == Operator.emark)
				suffXX = coreEnum.operator.suffNot.dataEntity;
			else if (op == Operator.qmark)
				suffXX = coreEnum.operator.suffRef.dataEntity;
			else
				assert(0);

			result = result.expectResolveIdentifier(ID!"#opSuffix").resolveCall(this, ctime, true, suffXX);
		}

		return result.Overloadset;
	}

	override AST_ParentCommaExpression isParentCommaExpression() {
		return null;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange();
	}

}
