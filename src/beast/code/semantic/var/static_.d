module beast.code.semantic.var.static_;

import beast.code.semantic.toolkit;
import beast.code.semantic.var.variable;

/// User (programmer) defined variable
abstract class Symbol_StaticVariable : Symbol_Variable {

protected:
	this(DataEntity parent) {
		parent_ = parent;
		staticData_ = new Data(this, MatchLevel.fullMatch);
	}

public:
	final override DeclType declarationType() {
		return DeclType.staticVariable;
	}

public:
	final override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		if (matchLevel != MatchLevel.fullMatch)
			return new Data(this, matchLevel);
		else
			return staticData_;
	}

	abstract bool isCtime();

	/// Pointer that holds (initial value for runtime variables) data of the variable
	abstract MemoryPtr memoryPtr();

	final DataEntity parent() {
		return parent_;
	}

private:
	Data staticData_;
	DataEntity parent_;

private:
	final static class Data : SymbolRelatedDataEntity {

	public:
		this(Symbol_StaticVariable sym, MatchLevel matchLevel) {
			// Static variables are in global scope
			super(sym, matchLevel);
			sym_ = sym;
		}

	public:
		override Symbol_Type dataType() {
			return sym_.dataType;
		}

		override bool isCtime() {
			return sym_.isCtime;
		}

		override DataEntity parent() {
			return sym_.parent_;
		}

		override string identificationString() {
			return "%s%s %s".format(isCtime ? "@ctime " : null, sym_.dataType.tryGetIdentificationString, identificationString_noPrefix);
		}

	public:
		override void buildCode(CodeBuilder cb) {
			auto _gd = ErrorGuard(this);

			cb.build_memoryAccess(sym_.memoryPtr);
		}

	private:
		Symbol_StaticVariable sym_;

	}

}
