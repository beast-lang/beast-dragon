module beast.code.data.alias_.btsp;

import beast.code.data.toolkit;
import beast.code.data.alias_.alias_;

class Symbol_BootstrapAlias : Symbol_Alias {

public:
	alias AliasFunction = Overloadset delegate(MatchLevel matchLevel, DataEntity parentInstance);

public:
	this(Identifier identifier, AliasFunction aliasFunc) {
		identifier_ = identifier;
		aliasFunc_ = aliasFunc;
	}

public:
	override Identifier identifier() {
		return identifier_;
	}

	override DeclType declarationType() {
		return DeclType.alias_;
	}

public:
	override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		assert(0); // This should not happen as only overloadset should be called
	}

	override Overloadset overloadset(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		return aliasFunc_(matchLevel, parentInstance);
	}

private:
	Identifier identifier_;
	AliasFunction aliasFunc_;

}
