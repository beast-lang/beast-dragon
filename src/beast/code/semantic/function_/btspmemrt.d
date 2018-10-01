/// BooTStraP MEMber RunTime
module beast.code.semantic.function_.btspmemrt;

import beast.code.semantic.function_.toolkit;
import beast.code.ast.decl.function_;
import beast.code.decorationlist;
import beast.code.ast.decl.env;
import beast.code.semantic.scope_.blurry;
import beast.code.semantic.function_.paramlist;
import beast.code.semantic.var.mem;
import std.range;

final class Symbol_BootstrapMemberRuntimeFunction : Symbol_RuntimeFunction {

public:
	this(Symbol_Type parent, Identifier identifier, Symbol_Type returnType, ExpandedFunctionParameter[] paramList) {
		staticData_ = new Data(this, MatchLevel.fullMatch, null);

		parent_ = parent;
		identifier_ = identifier;
		paramList_ = paramList;
		returnType_ = returnType;

		auto thisPtr = new DataEntity_ContextPointer(ID!"this", parent_, false);
		paramsScope_ = new RootDataScope(dataEntity(MatchLevel.fullMatch, thisPtr));
		auto _sgd = paramsScope_.scopeGuard;
		paramsScope_.addEntity(thisPtr);
	}

	override Identifier identifier() {
		return identifier_;
	}

	override Symbol_Type returnType() {
		return returnType_;
	}

	override Symbol_Type contextType() {
		return parent_;
	}

	override ExpandedFunctionParameter[] parameters() {
		return expandedParametersWIP_;
	}

	override DeclType declarationType() {
		return DeclType.memberFunction;
	}

public:
	override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		if (matchLevel != MatchLevel.fullMatch || parentInstance)
			return new Data(this, matchLevel, parentInstance);
		else
			return staticData_;
	}

protected:
	override void buildDefinitionsCode(CodeBuilder cb, StaticMemberMerger staticMemberMerger) {
		assert(!cb.isCtime);

		// We open the new subscope as blurry, because multiple buildDefinitionsCode calls might be used the paramsScopeWIP_
		auto _sgd = new BlurryDataScope(paramsScope_).scopeGuard;
		auto _gd = ErrorGuard(codeLocation);

		cb.build_functionDefinition(this, (cb) { //
			scope env = DeclarationEnvironment.newFunctionBody();
			env.staticMembersParent = parent_.dataEntity;
			env.staticMemberMerger = staticMemberMerger;
			env.functionReturnType = returnType;

			ast_.body_.buildStatementCode(env, cb);

			if (returnType_ is coreType.Void)
				cb.build_return(null);

		}).inSession(SessionPolicy.watchCtChanges);
	}

private:
	Symbol_Type parent_;
	Identifier identifier_;
	ExpandedFunctionParameter[] paramList_;
	Symbol_Type returnType_;
	RootDataScope paramsScope_;

private:
	Data staticData_;

protected:
	final class Data : typeof(super).Data {

	public:
		this(Symbol_UserMemberRuntimeFunction sym, MatchLevel matchLevel, DataEntity parentInstance) {
			assert(this.outer);
			super(sym, matchLevel | MatchLevel.staticCall);

			sym_ = sym;
			parentInstance_ = parentInstance;
		}

	public:
		override DataEntity parent() {
			return parentInstance_ ? parentInstance_ : sym_.parent_.dataEntity;
		}

		override CallableMatch startCallMatch(AST_Node ast, bool canThrowErrors, MatchLevel matchLevel) {
			if (parentInstance_) {
				benforce(parentInstance_.dataType is sym_.parent_, E.invalidParentDataType, "Context for %s should be %s, not %s".format(this, sym_.parent_, parentInstance_.dataType));
				return new Match(sym_, this, parentInstance_, ast, canThrowErrors, matchLevel | this.matchLevel);
			}
			else {
				benforce(!canThrowErrors, E.needThis, "Need this for %s".format(this.tryGetIdentificationString));
				return new InvalidCallableMatch(this, "need this");
			}
		}

	private:
		Symbol_UserMemberRuntimeFunction sym_;
		DataEntity parentInstance_;

	}

}
