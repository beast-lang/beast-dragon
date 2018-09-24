module beast.code.ast.expr.expression;

import beast.code.ast.toolkit;
import beast.code.ast.expr.auto_;
import beast.code.ast.expr.vardecl;
import beast.code.memory.ptr;
import beast.code.memory.memorymgr;
import beast.code.semantic.scope_.root;
import beast.code.ast.expr.assign;
import std.typecons : Tuple;
import beast.code.ast.expr.parentcomma;
import beast.code.ast.expr.decorated;

abstract class AST_Expression : AST_Statement {
	alias LowerLevelExpression = AST_AssignExpression;

public:
	static bool canParse() {
		return LowerLevelExpression.canParse || AST_DecorationList.canParse;
	}

	static AST_Expression parse(bool parseDeclarations = true) {
		auto _gd = codeLocationGuard();

		AST_DecorationList decorationList;
		if (AST_DecorationList.canParse)
			decorationList = AST_DecorationList.parse();

		auto result = LowerLevelExpression.parse();

		if (parseDeclarations && result.isPrefixExpression && currentToken == Token.Type.identifier)
			result = AST_VariableDeclarationExpression.parse(_gd, null, result);

		if (decorationList) {
			result = new AST_DecoratedExpression(decorationList, result);
			result.codeLocation = _gd.get();
		}

		return result;
	}

public:
	/// Returns if the expression is P1 or lower
	bool isPrefixExpression() {
		return false;
	}

	/// Returns if the expression is auto (auto or auto? or auto ?! etc.)
	AST_AutoExpression isAutoExpression() {
		return null;
	}

	/// Returns if the expression is variable declaration
	AST_VariableDeclarationExpression isVariableDeclaration() {
		return null;
	}

	AST_ParentCommaExpression isParentCommaExpression() {
		return null;
	}

	AST_DecoratedExpression isDecoratedExpression() {
		return null;
	}

	Tuple!(AST_Expression, AST_ParentCommaExpression) asNewRightExpression() {
		auto _gd = ErrorGuard(this);
		berror(E.syntaxError, "The 'new' expression has to end with '( args )'");
		assert(0);
	}

public:
	/// Builds semantic tree (no code is built) for this expression and returns data entity representing the result.
	/// inferType is used for type inferration and can be null (any result is then acceptable)
	/// The scope is used only for identifier lookup
	/// Can result in executing ctime code
	/// If errorOnInferrationFailure is false, returns null data entity if the expression cannot be built with given inferredType
	abstract Overloadset buildSemanticTree(Symbol_Type inferredType, bool ctime, bool errorOnInferrationFailure = true);

	/// Builds semantic tree (with inferration of iniferredType), checks if the overloadset returns anything
	/// The result DataEntity dataType can differ from infferedType!
	final DataEntity buildSemanticTree_singleInfer(Symbol_Type inferredType, bool ctime, bool errorOnInferrationFailure = true) {
		Overloadset result = buildSemanticTree(inferredType, ctime, errorOnInferrationFailure);

		if (!result.length && !errorOnInferrationFailure)
			return null;

		return result.single;
	}

	/// Builds semantic tree (with inferration of expectedType), checks if the overloadset returns anything and enforces the result to be of type expectedType
	final DataEntity buildSemanticTree_singleExpect(Symbol_Type expectedType, bool ctime, bool errorOnInferrationFailure = true) {
		Overloadset result = buildSemanticTree(expectedType, ctime, errorOnInferrationFailure);

		if (!result.length && !errorOnInferrationFailure)
			return null;

		DataEntity resultEntity = result.single_expectType(expectedType);

		assert(resultEntity.dataType is expectedType);
		return resultEntity;
	}

	/// Builds semantic tree, andchecks if the overloadset returns anything
	final DataEntity buildSemanticTree_single(bool ctime, bool errorOnInferrationFailure = true) {
		Overloadset result = buildSemanticTree(null, ctime, errorOnInferrationFailure);

		if (!result.length && !errorOnInferrationFailure)
			return null;

		return result.single;
	}

	override void buildStatementCode(DeclarationEnvironment env, CodeBuilder cb) {
		auto _gd = ErrorGuard(codeLocation);

		// Statement code is built and executed in subsession so non-@ctime expression statements cannot modify @ctime variables outside (because of separate semantic tree building (where @ctime stuff is done) and execution)
		// For @ctime statements, this is resolved in override of buildStatementCode in decoratedExpression
		if (cb.isCtime)
			cb.build_scope(&buildSemanticTree_single(true).buildCode);
		else
			cb.build_scope(&buildSemanticTree_single(false).buildCode).inSubSession;
	}

	final CTExecResult ctExec(Symbol_Type expectedType) {
		const auto __gd = ErrorGuard(codeLocation);
		return buildSemanticTree_singleExpect(expectedType, true).ctExec();
	}

	pragma(inline) final Symbol_Type ctExec_asType() {
		const auto __gd = ErrorGuard(codeLocation);
		return buildSemanticTree_singleExpect(coreType.Type, true).ctExec_asType();
	}

}
