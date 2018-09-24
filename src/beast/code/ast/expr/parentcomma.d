module beast.code.ast.expr.parentcomma;

import beast.code.ast.toolkit;
import beast.code.ast.expr.suffix;
import beast.code.semantic.callable.match;
import beast.code.ast.expr.vardecl;
import beast.code.semantic.matchlevel;

/// Parameter list used in declarations
final class AST_ParentCommaExpression : AST_Expression, AST_SuffixExpressionItem {

public:
	static bool canParse() {
		return currentToken == Token.Special.lParent;
	}

	static AST_ParentCommaExpression parse() {
		auto _gd = codeLocationGuard();
		auto result = new AST_ParentCommaExpression();

		currentToken.expectAndNext(Token.Special.lParent);

		if (AST_Expression.canParse) {
			do
				result.items ~= AST_Expression.parse();
			while (currentToken.matchAndNext(Token.Special.comma));

			currentToken.expectAndNext(Token.Special.rParent, "',' or ')'");
		}
		else
			currentToken.expectAndNext(Token.Special.rParent, "expression or ')'");

		result.codeLocation = _gd.get();
		return result;
	}

public:
	AST_Expression[] items;

public:
	override AST_ParentCommaExpression isParentCommaExpression() {
		return this;
	}

public:
	override Overloadset buildSemanticTree(Symbol_Type inferredType, bool ctime, bool errorOnInferrationFailure = true) {
		const auto __gd = ErrorGuard(codeLocation);

		// Maybe replace with void?
		benforce(items.length > 0, E.syntaxError, "Empty parentheses");

		// We're passing null as inferredType because inferredType only applies to the rightmost part of the expression
		DataEntity[] payload = items[0 .. $ - 1].map!(x => x.buildSemanticTree_single(ctime)).array;

		DataEntity base = items[$ - 1].buildSemanticTree_singleInfer(inferredType, ctime, errorOnInferrationFailure);

		// If errorOnInferrationFailure is false then entity might be null (inferration failure)
		if (!base)
			return Overloadset();

		if (payload.length == 0)
			return base.Overloadset;

		return new DataEntity_ParentComma(payload, base, this).Overloadset;
	}

	override Overloadset p1expressionItem_buildSemanticTree(Overloadset leftSide, bool ctime) {
		const auto _gd = ErrorGuard(this);
		return leftSide.resolveCall(this, ctime, true, items).Overloadset;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(items);
	}

}

/// Data entity which executes additional code
private final class DataEntity_ParentComma : DataEntity {

public:
	this(DataEntity[] payload, DataEntity base, AST_ParentCommaExpression ast) {
		super(base.matchLevel);
		payload_ = payload;
		base_ = base;
	}

public:
	override Symbol_Type dataType() {
		return base_.dataType;
	}

	override DataEntity parent() {
		return base_;
	}

	override bool isCtime() {
		import std.algorithm.searching : all;

		return base_.isCtime && payload_.all!(x => x.isCtime);
	}

	override bool isCallable() {
		return base_.isCallable;
	}

	override CallableMatch startCallMatch(AST_Node ast, bool ctime, bool canThrowErrors, MatchLevel matchLevel) {
		return base_.startCallMatch(ast, ctime, canThrowErrors, matchLevel | this.matchLevel);
	}

public:
	override string identification() {
		return "( %s )".format((payload_ ~ base_).map!(x => x.identificationString).joiner(", ").to!string);
	}

	override AST_Node ast() {
		return ast_;
	}

public:
	override void buildCode(CodeBuilder cb) {
		foreach (pl; payload_)
			pl.buildCode(cb);

		base_.buildCode(cb);
	}

private:
	DataEntity[] payload_;
	DataEntity base_;
	AST_ParentCommaExpression ast_;

}
