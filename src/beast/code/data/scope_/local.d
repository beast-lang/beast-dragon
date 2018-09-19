module beast.code.data.scope_.local;

import beast.code.data.toolkit;

final class LocalDataScope : DataScope {

public:
	this() {
		assert(currentScope);
		super(currentScope.parentEntity);

		parentScope_ = currentScope;

		debug {
			assert(parentScope_.openSubscope_ is null);
			parentScope_.openSubscope_ = this;
		}
	}

public:
	debug override void finish(string file = __FILE__, ulong line = __LINE__) {
		super.finish(file, line);

		assert(parentScope_.openSubscope_ is this);
		parentScope_.openSubscope_ = null;
	}

public:
	final Overloadset tryRecursivelyResolveIdentifier(Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch) {
		if (auto result = tryResolveIdentifier(id, matchLevel))
			return result;

		if (auto result = parentScope_.tryRecursivelyResolveIdentifier(id, matchLevel))
			return result;

		return Overloadset();
	}

private:
	DataScope parentScope_;

}
