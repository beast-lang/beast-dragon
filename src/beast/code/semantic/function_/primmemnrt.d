module beast.code.semantic.function_.primmemnrt;

import beast.code.semantic.function_.toolkit;
import beast.code.semantic.function_.nonrt;
import beast.code.semantic.function_.nrtparambuilder;

final class Symbol_PrimitiveMemberNonRuntimeFunction : Symbol_NonRuntimeFunction {

public:
	static auto paramsBuilder() {
		return Builer_Base!(true, Data)();
	}

public:
	this(Identifier id, Symbol_Type parent, CallMatchFactory!(true, Data) matchFactory) {
		parent_ = parent;
		id_ = id;
		matchFactory_ = matchFactory;

		staticData_ = new Data(this, null, MatchLevel.fullMatch);
	}

public:
	override DeclType declarationType() {
		return DeclType.memberFunction;
	}

	override Identifier identifier() {
		return id_;
	}

public:
	override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		if (parentInstance || matchLevel != MatchLevel.fullMatch)
			return new Data(this, parentInstance, matchLevel);
		else
			return staticData_;
	}

private:
	Symbol_Type parent_;
	Identifier id_;
	CallMatchFactory!(true, Data) matchFactory_;
	Data staticData_;

protected:
	final static class Data : typeof(super).Data {

	public:
		this(Symbol_PrimitiveMemberNonRuntimeFunction sym, DataEntity parentInstance, MatchLevel matchLevel) {
			super(sym, matchLevel);
			sym_ = sym;
			parentInstance_ = parentInstance;
		}

	public:
		override string identification() {
			return "%s( %s )".format(sym_.identifier.str, sym_.matchFactory_.argumentsIdentificationStrings.joiner(", "));
		}

		override string identificationString_noPrefix() {
			return "%s.%s".format(sym_.parent_.identificationString, identification);
		}

		override Symbol_Type dataType() {
			// TODO: better
			return coreType.Void;
		}

		final override DataEntity parent() {
			return sym_.parent_.dataEntity;
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
		override CallableMatch startCallMatch(AST_Node ast, bool ctime, bool canThrowErrors, MatchLevel matchLevel) {
			if (parentInstance_) {
				benforce(parentInstance_.dataType is sym_.parent_, E.invalidParentDataType, "Context for %s should be %s, not %s".format(this, sym_.parent_, parentInstance_.dataType));
				return sym_.matchFactory_.startCallMatch(this, ast, ctime, canThrowErrors, matchLevel | this.matchLevel);
			}
			else {
				benforce(!canThrowErrors, E.needThis, "Need this for %s".format(this.tryGetIdentificationString));
				return new InvalidCallableMatch(this, "need this");
			}
		}

	protected:
		Symbol_PrimitiveMemberNonRuntimeFunction sym_;
		DataEntity parentInstance_;

	}

}
