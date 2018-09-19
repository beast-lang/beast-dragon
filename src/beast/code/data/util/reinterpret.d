module beast.code.data.util.reinterpret;

import beast.code.data.toolkit;

/// Data entity that "reinterpret casts" source data entity into different datatype (no data change)
final class DataEntity_ReinterpretCast : DataEntity {

public:
	this(DataEntity sourceEntity, Symbol_Type newType, MatchLevel matchLevel = MatchLevel.fullMatch) {
		super(matchLevel);
		newType_ = newType;
		sourceEntity_ = sourceEntity;
	}

public:
	override Symbol_Type dataType() {
		return newType_;
	}

	override DataEntity parent() {
		return sourceEntity_.parent;
	}

	override bool isCtime() {
		return sourceEntity_.isCtime;
	}

public:
	override AST_Node ast() {
		return sourceEntity_.ast;
	}

	override string identification() {
		return "%s.##reinterpretCast( %s )".format(super.identification, newType_.identificationString);
	}

	override Hash outerHash() {
		return super.outerHash + newType_.outerHash;
	}

	override void buildCode(CodeBuilder cb) {
		sourceEntity_.buildCode(cb);
	}

private:
	Symbol_Type newType_;
	DataEntity sourceEntity_;

}
