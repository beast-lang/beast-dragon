module beast.code.namespace.rootscope;

import beast.code.namespace.scope_;
import beast.code.entity.dataentity;

final class SubScope : Scope {

public:
	this(Scope parent) {
		parent_ = parent;
	}

public:
	override DataEntity[] resolveIdentifier(Identifier identifier, ResolutionFlags flags) {
		if (auto result = super.resolveIdentifier(identifier, flags))
			return result;

		if (!(flags & ResolutionFlag.noRecursion))
			return parent_.resolveIdentifier(identifier, flags);

		return null;
	}

private:
	Scope parent_;

}
