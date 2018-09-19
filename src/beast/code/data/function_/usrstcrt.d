/// USeR StaTiC RunTime
module beast.code.data.function_.usrstcrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.function_;
import beast.code.decorationlist;
import beast.code.ast.decl.env;
import beast.code.data.scope_.blurry;
import beast.code.data.function_.paramlist;

final class Symbol_UserStaticRuntimeFunction : Symbol_RuntimeFunction {
	mixin TaskGuard!"returnTypeDeduction";
	mixin TaskGuard!"parameterExpanding";

public:
	this(AST_FunctionDeclaration ast, DecorationList decorationList, FunctionDeclarationData data, FunctionParameterList paramList) {
		staticData_ = new Data(this, MatchLevel.fullMatch);

		ast_ = ast;
		decorationList_ = decorationList;
		parent_ = data.env.staticMembersParent;
		paramList_ = paramList;

		taskManager.delayedIssueJob({ enforceDone_parameterExpanding(); });
		taskManager.delayedIssueJob({ enforceDone_returnTypeDeduction(); });

		decorationList_.enforceAllResolved(); // TODO: move somewhere else eventually
	}

	override Identifier identifier() {
		return ast_.identifier;
	}

	override Symbol_Type returnType() {
		enforceDone_returnTypeDeduction();
		return returnTypeWIP_;
	}

	override Symbol_Type contextType() {
		return null;
	}

	override ExpandedFunctionParameter[] parameters() {
		enforceDone_parameterExpanding();
		return expandedParametersWIP_;
	}

	override AST_Node ast() {
		return ast_;
	}

	override DeclType declarationType() {
		return DeclType.staticFunction;
	}

public:
	override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		if (matchLevel != MatchLevel.fullMatch)
			return new Data(this, matchLevel);
		else
			return staticData_;
	}

protected:
	override void buildDefinitionsCode(CodeBuilder cb, StaticMemberMerger staticMemberMerger) {
		assert(!cb.isCtime);
		enforceDone_parameterExpanding();

		auto _gd = ErrorGuard(codeLocation);

		cb.build_functionDefinition(this, (cb) { //
			scope env = DeclarationEnvironment.newFunctionBody();
			env.staticMembersParent = parent_;
			env.staticMemberMerger = staticMemberMerger;

			if (!ast_.returnType.isAutoExpression)
				env.functionReturnType = returnType;

			ast_.body_.buildStatementCode(env, cb);

			/*
						If the return type is auto and the staticMemberMerger is not finished (meaning this definition building is the 'main' codeProcessing one),
						we deduce a return type from the first encountered return statement (which sets env.functionReturnType if it was null previously)
					*/
			if (ast_.returnType.isAutoExpression && !staticMemberMerger.isFinished)
				returnTypeWIP_ = env.functionReturnType ? env.functionReturnType : coreType.Void;

			// returnTypeWIP_ is definitely accessible now (we called returnType before in this function or eventually set the value ourselves)
			if (returnTypeWIP_ is coreType.Void)
				cb.build_return(null);

		}).inSession(SessionPolicy.watchCtChanges).inBlurryDataScope(paramsScopeWIP_);
		// We open the new subscope as blurry, because multiple buildDefinitionsCode calls might be used the paramsScopeWIP_
	}

private:
	ExpandedFunctionParameter[] expandedParametersWIP_;
	Symbol_Type returnTypeWIP_;
	RootDataScope paramsScopeWIP_;

private:
	AST_FunctionDeclaration ast_;
	DecorationList decorationList_;
	FunctionParameterList paramList_;
	Data staticData_;
	DataEntity parent_;

protected:
	final void execute_returnTypeDeduction() {
		auto _gd = ErrorGuard(codeLocation);

		// If the return type is auto, the type is inferred in the buildDefinitionsCode function (which is run from the codeProcessing)
		if (ast_.returnType.isAutoExpression)
			enforceDone_codeProcessing();
		else {
			enforceDone_parameterExpanding();
			returnTypeWIP_ = ast_.returnType.ctExec_asType.inStandaloneSession.inBlurryDataScope(paramsScopeWIP_);
		}
	}

	final void execute_parameterExpanding() {
		auto _gd = ErrorGuard(codeLocation);

		with (memoryManager.session(SessionPolicy.doNotWatchCtChanges)) {
			paramsScopeWIP_ = new RootDataScope(staticData_);
			debug paramsScopeWIP_.allowMultiThreadAccess = true;
			auto _sgd = paramsScopeWIP_.scopeGuard;

			expandedParametersWIP_ = paramList_.expandAsRuntimeParameterList();
		}
	}

protected:
	final class Data : typeof(super).Data {

	public:
		this(Symbol_UserStaticRuntimeFunction sym, MatchLevel matchLevel) {
			assert(this.outer);
			super(sym, matchLevel | MatchLevel.staticCall);

			sym_ = sym;
		}

	public:
		override DataEntity parent() {
			return sym_.parent_;
		}

	private:
		Symbol_UserStaticRuntimeFunction sym_;

	}

}
