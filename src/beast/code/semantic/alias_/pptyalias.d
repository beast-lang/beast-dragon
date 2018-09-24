module beast.code.semantic.alias_.pptyalias;

import beast.code.semantic.toolkit;
import beast.code.semantic.alias_.alias_;
import beast.code.semantic.function_.rt;
import beast.code.semantic.util.proxy;

class Symbol_PropertyAlias : Symbol_Alias {

public:
	this(Symbol_RuntimeFunction aliasedFunc) {
		aliasedFunc_ = aliasedFunc;
	}

public:
	override Identifier identifier() {
		return aliasedFunc_.identifier;
	}

	override DeclType declarationType() {
		return DeclType.alias_;
	}

public:
	override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		return new ProxyData(aliasedFunc_.dataEntity(matchLevel, parentInstance), matchLevel);
	}

private:
	Symbol_RuntimeFunction aliasedFunc_;

private:
	static final class ProxyData : ProxyDataEntity {

	public:
		this(DataEntity sourceEntity, MatchLevel matchLevel) {
			sourceEntity_ = sourceEntity;
			callEntity_ = sourceEntity.resolveCall(null, false, true);

			super(callEntity_, matchLevel);
		}

	protected:
		override Overloadset _resolveIdentifier_main(Identifier id, MatchLevel matchLevel) {
			if (id == ID!"#property")
				return sourceEntity_.Overloadset;

			return callEntity_.tryResolveIdentifier(id, matchLevel);
		}

	private:
		DataEntity sourceEntity_, callEntity_;

	}

}
