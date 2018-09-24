module beast.code.ast.expr.decorated;

import beast.code.ast.toolkit;
import beast.code.decorationlist;
import beast.code.semantic.util.ctexec;
import beast.code.memory.memorymgr;
import beast.backend.ctime.codebuilder;
import beast.core.ctxctimeguard;

final class AST_DecoratedExpression : AST_Expression {

public:
	alias ValueTransformer = Overloadset delegate(Overloadset);

public:
	this(AST_DecorationList decorationList, AST_Expression baseExpression) {
		this.decorationList = decorationList;
		this.baseExpression = baseExpression;
	}

public:
	override bool isPrefixExpression() {
		return baseExpression.isPrefixExpression;
	}

	override AST_DecoratedExpression isDecoratedExpression() {
		return this;
	}

public:
	override Overloadset buildSemanticTree(Symbol_Type inferredType, bool errorOnInferrationFailure = true) {
		auto _gd = ErrorGuard(codeLocation);
		auto decoData = new ExpressionDecorationData;
		auto decoList = new DecorationList(decorationList);

		decoList.apply_expressionDecorator(decoData);

		return buildSemanticTree(inferredType, decoData, decoList, errorOnInferrationFailure);
	}

	Overloadset buildSemanticTree(Symbol_Type inferredType, ExpressionDecorationData decoData, DecorationList decoList, bool errorOnInferrationFailure = true) {
		auto _gd = ErrorGuard(codeLocation);
		decoList.enforceAllResolved();

		// TODO: Special case where baseExpression is variable declaration
		auto result = baseExpression.buildSemanticTree(inferredType, errorOnInferrationFailure);

		if (decoData.isCtime)
			result = result.map!(x => cast(DataEntity) new DataEntity_CtExecProxy(x)).Overloadset;
		else
			assert(0, "Ctime is the only decorator for expressions so far, so this should not happen");

		return result;
	}

	override void buildStatementCode(DeclarationEnvironment env, CodeBuilder cb) {
		auto _gd = ErrorGuard(codeLocation);

		auto decoData = new ExpressionDecorationData;
		auto decoList = new DecorationList(decorationList);

		decoList.apply_expressionDecorator(decoData);

		if (cb.isCtime)
			cb.build_scope(&buildSemanticTree(null, decoData, decoList).single.buildCode);
		else if (decoData.isCtime) {
			auto __cgd = ContextCtimeGuard(true);
			new CodeBuilder_Ctime().build_scope(&buildSemanticTree(null, decoData, decoList).single.buildCode);
		}
		else
			cb.build_scope(&buildSemanticTree(null, decoData, decoList).single.buildCode).inSubSession;
	}

public:
	AST_DecorationList decorationList;
	AST_Expression baseExpression;

}

final class ExpressionDecorationData {

public:
	bool isCtime;

}
