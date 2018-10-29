module beast.code.entity.alias_.pptyalias;

import beast.code.entity.toolkit;
import beast.code.entity.alias_.alias_;
import beast.code.entity.function_.rt;
import beast.code.entity.util.proxy;

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
			callEntity_ = sourceEntity.resolveCall(null, true);

			super(callEntity_, matchLevel);
		}

	protected:
		override Overloadset _resolveIdentifier_main(Identifier id, MatchLevel matchLevel) {
			if (id == ID!"#property")
				return sourceEntity_.Overloadset;

			return callEntity_.resolveIdentifier(id, matchLevel);
		}

	private:
		DataEntity sourceEntity_, callEntity_;

	}

}
