module beast.code.semantic.util.direct;

import beast.code.semantic.toolkit;
import beast.code.semantic.util.proxy;
import beast.backend.common.primitiveop;

/// Data entity whoe identifier resolution is cut down only to direct members (no this aliases etc)
final static class DataEntity_DirectProxy : ProxyDataEntity {

public:
	this(DataEntity sourceEntity) {
		super(sourceEntity, MatchLevel.fullMatch);
	}

protected:
	override Overloadset _resolveIdentifier_main(Identifier id, MatchLevel matchLevel) {
		return sourceEntity_.dataType.expectResolveIdentifier_direct(id, sourceEntity_, matchLevel);
	}

}
