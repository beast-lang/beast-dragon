module beast.code.data.util.deref;

import beast.code.data.toolkit;
import beast.code.data.util.proxy;
import beast.backend.common.primitiveop;

final static class DataEntity_DereferenceProxy : ProxyDataEntity {

public:
	this(DataEntity sourceEntity, Symbol_Type baseType) {
		super(sourceEntity, MatchLevel.fullMatch);
		baseType_ = baseType;
	}

public:
	override Symbol_Type dataType() {
		return baseType_;
	}

public:
	override string identification() {
		return "%s.##dereference".format(super.identification);
	}

	override Hash outerHash() {
		return super.outerHash + baseType_.outerHash;
	}

public:
	override void buildCode(CodeBuilder cb) {
		cb.build_dereference(&sourceEntity_.buildCode);
	}

private:
	Symbol_Type baseType_;

}
