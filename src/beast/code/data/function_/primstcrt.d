/// PRIMitive STatiC RunTime
module beast.code.data.function_.primstcrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.env;
import beast.code.data.var.local;
import beast.backend.common.primitiveop;

/// Primitive (compiler-defined, handled by backend) static runtime (non-templated) function
/// Calling primitive functions doesn't result in funciton call - given code is injected directly (like inline)
final class Symbol_PrimitiveStaticRuntimeFunction : Symbol_RuntimeFunction {

public:
	alias PrimitiveFunc = void delegate(CodeBuilder cb, DataEntity[] args);

public:
	this(Identifier identifier, DataEntity parent, Symbol_Type returnType, ExpandedFunctionParameter[] parameters, PrimitiveFunc func) {
		staticData_ = new Data(this, MatchLevel.fullMatch);

		identifier_ = identifier;
		parent_ = parent;
		returnType_ = returnType;
		parameters_ = parameters;
		func_ = func;
	}

	override Identifier identifier() {
		return identifier_;
	}

	override Symbol_Type returnType() {
		return returnType_;
	}

	override Symbol_Type contextType() {
		return null;
	}

	override ExpandedFunctionParameter[] parameters() {
		return parameters_;
	}

	override DeclType declarationType() {
		return DeclType.memberFunction;
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
		// Do nothing
	}

private:
	Identifier identifier_;
	DataEntity parent_;
	Symbol_Type returnType_;
	Data staticData_;
	ExpandedFunctionParameter[] parameters_;
	PrimitiveFunc func_;

protected:
	final class Data : typeof(super).Data {

	public:
		this(Symbol_PrimitiveStaticRuntimeFunction sym, MatchLevel matchLevel) {
			super(sym, matchLevel | MatchLevel.staticCall);

			sym_ = sym;
		}

	public:
		override DataEntity parent() {
			return sym_.parent_;
		}

		override CallableMatch startCallMatch(AST_Node ast, bool canThrowErrors, MatchLevel matchLevel) {
			return new Match(sym_, this, ast, canThrowErrors, matchLevel | this.matchLevel);
		}

	private:
		Symbol_PrimitiveStaticRuntimeFunction sym_;

	}

	final class Match : typeof(super).Match {

	public:
		this(Symbol_PrimitiveStaticRuntimeFunction sym, Data sourceEntity, AST_Node ast, bool canThrowErrors, MatchLevel matchLevel) {
			super(sym, sourceEntity, null, ast, canThrowErrors, matchLevel);

			sym_ = sym;
		}

	protected:
		override DataEntity _toDataEntity() {
			return new MatchData(sym_, this);
		}

	private:
		Symbol_PrimitiveStaticRuntimeFunction sym_;

	}

	final class MatchData : typeof(super).MatchData {

	public:
		this(Symbol_PrimitiveStaticRuntimeFunction sym, Match match) {
			super(sym, match);

			sym_ = sym;
		}

	public:
		override void buildCode(CodeBuilder cb) {
			const auto _gd = ErrorGuard(codeLocation);

			sym_.func_(cb, arguments_);
		}

	private:
		Symbol_PrimitiveStaticRuntimeFunction sym_;

	}

}
