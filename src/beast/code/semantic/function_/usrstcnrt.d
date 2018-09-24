module beast.code.semantic.function_.usrstcnrt;

import beast.code.semantic.function_.toolkit;
import beast.code.semantic.function_.nonrt;
import beast.code.ast.decl.function_;
import beast.code.semantic.function_.paramlist;
import beast.code.decorationlist;
import beast.code.ast.expr.vardecl;
import beast.code.semantic.var.btspconst;
import beast.code.semantic.util.subst;
import beast.code.ast.decl.env;
import beast.util.uidgen;
import beast.core.ctxctimeguard;

final class Symbol_UserStaticNonRuntimeFunction : Symbol_NonRuntimeFunction {

public:
	this(AST_FunctionDeclaration ast, DecorationList decorationList, FunctionDeclarationData data, FunctionParameterList paramList) {
		ast_ = ast;
		decorationList_ = decorationList;
		parent_ = data.env.staticMembersParent;
		paramList_ = paramList;

		staticData_ = new Data(this, null, MatchLevel.fullMatch);
	}

public:
	override DeclType declarationType() {
		return DeclType.memberFunction;
	}

	override Identifier identifier() {
		return ast_.identifier;
	}

public:
	override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		if (parentInstance || matchLevel != MatchLevel.fullMatch)
			return new Data(this, parentInstance, matchLevel);
		else
			return staticData_;
	}

private:
	DataEntity parent_;
	AST_FunctionDeclaration ast_;
	FunctionParameterList paramList_;
	DecorationList decorationList_;
	Data staticData_;
	UIDGenerator instanceIdGenerator_;

protected:
	final static class Data : typeof(super).Data {

	public:
		this(Symbol_UserStaticNonRuntimeFunction sym, DataEntity parentInstance, MatchLevel matchLevel) {
			super(sym, matchLevel);
			sym_ = sym;
			parentInstance_ = parentInstance;
		}

	public:
		override string identification() {
			// TODO: better identification?
			if (auto loc = sym_.ast_.parameterList.codeLocation)
				return "%s%s".format(sym_.identifier.str, loc.shortContent);
			else
				return "%s( ... )".format(sym_.identifier.str);
		}

		override string identificationString_noPrefix() {
			return "%s.%s".format(sym_.parent_.identificationString, identification);
		}

		override Symbol_Type dataType() {
			// TODO: better
			return coreType.Void;
		}

		final override DataEntity parent() {
			return sym_.parent_;
		}

		final override bool isCtime() {
			return true;
		}

		final override bool isCallable() {
			return true;
		}

	public:
		DataEntity parentInstance() {
			return parentInstance_;
		}

	public:
		override CallableMatch startCallMatch(AST_Node ast, bool canThrowErrors, MatchLevel matchLevel) {
			return new Match(sym_, this, null, ast, canThrowErrors, this.matchLevel | matchLevel);
		}

	protected:
		Symbol_UserStaticNonRuntimeFunction sym_;
		DataEntity parentInstance_;

	}

	static class Match : SeriousCallableMatch {

	public:
		this(Symbol_UserStaticNonRuntimeFunction sym, DataEntity sourceEntity, DataEntity parentInstance, AST_Node ast, bool canThrowErrors, MatchLevel matchLevel) {
			super(sourceEntity, ast, canThrowErrors, matchLevel);
			sym_ = sym;
			sourceEntity_ = sourceEntity;
			parentInstance_ = parentInstance;
			parametersScope_ = new RootDataScope(sym.staticData_);

			debug parametersScope_.allowMultiThreadAccess = true;
		}

	protected:
		override MatchLevel _matchNextArgument(AST_Expression expression, DataEntity entity, Symbol_Type dataType) {
			auto _sgd = scope_.scopeGuard(false);
			MatchLevel result = MatchLevel.fullMatch;

			// TODO: variadic arguments, default values
			if (argumentIndex_ >= sym_.paramList_.parameterCount) {
				errorStr = "too many arguments";
				return MatchLevel.noMatch;
			}

			auto paramData = sym_.paramList_.paramData(argumentIndex_);

			// Declaration -> standard parameter
			if (AST_VariableDeclarationExpression decl = paramData.ast.isVariableDeclaration) {
				Symbol_Type expectedType = decl.dataType.isAutoExpression ? null : decl.dataType.ctExec_asType().inStandaloneSession.inDataScope(parametersScope_, false);

				if (paramData.isCtime) {
					CTExecResult ctexec;
					result = matchCtimeArgument(expression, entity, dataType, expectedType, ctexec);

					if (result == MatchLevel.noMatch)
						return result;

					// We add a static ctime variable into the parameter list (as a result of @ctime variable expansion)
					// The data is copied over copy-ctor
					// TODO: check the data doesn't point anyhow to the current scope (it has to be copied comletely)
					// Standalone session realized in the bootstrapConstant constructor
					parametersScope_.addEntity(new Symbol_BootstrapConstant(sym_.staticData_, decl.identifier, scoped!SubstitutiveDataEntity(ctexec.value, dataType)));

					// TODO: store ctexec vars and add them to the scope (because destructor)
					ctexec.keepUntilSessionEnd();
				}
				else {
					result = matchStandardArgument(expression, entity, dataType, expectedType);

					auto expandedParam = new ExpandedFunctionParameter();
					expandedParam.identifier = decl.identifier;
					expandedParam.index = argumentIndex_;
					expandedParam.runtimeIndex = rtParamIndex_++;
					expandedParam.ast = paramData.ast;
					expandedParam.dataType = dataType;

					parametersScope_.addEntity(new DataEntity_FunctionParameter(expandedParam, false));

					expandedParams_ ~= expandedParam;
					arguments_ ~= entity;
				}
			}
			// otherwise constval parameter
			else {
				Symbol_Type constvalType;
				MemoryPtr constvalValue;

				with (memoryManager.subSession) {
					auto __cgd = ContextCtimeGuard(true);
					auto _sgd2 = parametersScope_.scopeGuard(false);
					// TODO: execute during semtree building
					auto semTree = paramData.ast.buildSemanticTree_single();
					constvalType = semTree.dataType;
					constvalValue = semTree.ctExec().keepUntilSessionEnd;
				}

				result |= matchConstValue(expression, entity, dataType, constvalType, constvalValue);
			}

			return result;
		}

		override MatchLevel _finish() {
			parametersScope_.finish();

			if (argumentIndex_ != sym_.paramList_.parameterCount) {
				errorStr = "not enough arguments";
				return MatchLevel.noMatch;
			}

			return MatchLevel.fullMatch | super._finish();
		}

		override DataEntity _toDataEntity() {
			// Duplicate the decoration list -- decorators will be applied to each function instance separately
			// TODO: join instances with same parameters
			auto expandedFunc = new Symbol_ExpandedUserStaticNonRuntimeFunction(sym_.instanceIdGenerator_(), sym_.ast_, sym_.parent_, new DecorationList(sym_.decorationList_), expandedParams_, parametersScope_);
			return expandedFunc.createMatchData(matchLevel, ast, arguments_, parentInstance_);
		}

	protected:
		size_t rtParamIndex_;
		Symbol_UserStaticNonRuntimeFunction sym_;
		RootDataScope parametersScope_;
		DataEntity sourceEntity_, parentInstance_;

	protected:
		DataEntity[] arguments_;
		ExpandedFunctionParameter[] expandedParams_;

	}

}

final class Symbol_ExpandedUserStaticNonRuntimeFunction : Symbol_RuntimeFunction {
	mixin TaskGuard!"returnTypeDeduction";

public:
	this(size_t instanceId, AST_FunctionDeclaration ast, DataEntity parent, DecorationList decorationList, ExpandedFunctionParameter[] expandedParameters, RootDataScope paramsScope) {
		staticData_ = new Data(this, MatchLevel.fullMatch);

		ast_ = ast;
		decorationList_ = decorationList;
		parent_ = parent;
		expandedParameters_ = expandedParameters;
		paramsScope_ = paramsScope;
		instanceId_ = instanceId;

		decorationList_.enforceAllResolved(); // TODO: move somewhere else eventually, add functionality?
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
		return expandedParameters_;
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

	DataEntity createMatchData(MatchLevel matchLevel, AST_Node ast, DataEntity[] arguments, DataEntity parentInstance) {
		return new MatchData(this, matchLevel, ast, arguments, parentInstance);
	}

protected:
	override void buildDefinitionsCode(CodeBuilder cb, StaticMemberMerger staticMemberMerger) {
		assert(!cb.isCtime);

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

		}).inSession(SessionPolicy.watchCtChanges).inBlurryDataScope(paramsScope_);
		// We open the new subscope as blurry, because multiple buildDefinitionsCode calls might be used the paramsScopeWIP_
	}

private:
	Symbol_Type returnTypeWIP_;

private:
	ExpandedFunctionParameter[] expandedParameters_;
	RootDataScope paramsScope_;
	AST_FunctionDeclaration ast_;
	DecorationList decorationList_;
	Data staticData_;
	DataEntity parent_;
	size_t instanceId_;

protected:
	final void execute_returnTypeDeduction() {
		auto _gd = ErrorGuard(codeLocation);

		// If the return type is auto, the type is inferred in the buildDefinitionsCode function (which is run from the codeProcessing)
		if (ast_.returnType.isAutoExpression)
			enforceDone_codeProcessing();
		else
			returnTypeWIP_ = ast_.returnType.ctExec_asType.inStandaloneSession.inBlurryDataScope(paramsScope_);
	}

	override void execute_outerHashObtaining() {
		super.execute_outerHashObtaining();
		outerHashWIP_ += Hash(instanceId_);
	}

protected:
	final class Data : typeof(super).Data {

	public:
		this(Symbol_ExpandedUserStaticNonRuntimeFunction sym, MatchLevel matchLevel) {
			assert(this.outer);
			super(sym, matchLevel | MatchLevel.staticCall);

			sym_ = sym;
		}

	public:
		override DataEntity parent() {
			return sym_.parent_;
		}

	private:
		Symbol_ExpandedUserStaticNonRuntimeFunction sym_;

	}

}
