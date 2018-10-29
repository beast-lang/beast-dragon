module beast.code.entity.scope_.root;

import beast.code.entity.toolkit;

/// Root scope = there is no parent scope (there is however parent_ dataEntity)
class RootDataScope : DataScope {

public:
	this(DataEntity parent) {
		super(parent);
	}

public:
	final Overloadset tryRecursivelyResolveIdentifier(Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch) {
		// First look into the scope
		if (auto result = resolveIdentifier(id, matchLevel))
			return result;

		// Then look into parent
		if (auto result = parentEntity.tryRecursivelyResolveIdentifier(id, matchLevel))
			return result;

		return Overloadset();
	}

}
