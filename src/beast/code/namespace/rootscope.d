module beast.code.namespace.rootscope;

import beast.code.namespace.scope_;
import beast.code.entity.dataentity;
import beast.code.symbol.symbol;

final class RootScope : Scope {

public:
	this(Symbol parent, DataEntity parentInstance) {
		parent_ = parent;
		parentInstance_ = parentInstance;
	}

public:
	override bool resolveIdentifier(void delegate(DataEntity) sink, Identifier identifier, ResolutionFlags flags) {
		if (super.resolveIdentifier(sink, identifier, flags))
			return true;

		if (!(flags & ResolutionFlag.noRecursion) && parent_.resolveIdentifier(sink, flags, parentInstance_))
			return true;

		return false;
	}

private:
	Symbol parent_;
	DataEntity parentInstance_;

}
