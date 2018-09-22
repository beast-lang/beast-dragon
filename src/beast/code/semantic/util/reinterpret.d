module beast.code.semantic.util.reinterpret;

import beast.code.semantic.toolkit;
import beast.code.semantic.util.proxy;

/// Data entity that "reinterpret casts" source data entity into different datatype (no data change)
final class SemanticNode_ReinterpretCast : ProxySemanticNode {

public:
	this(SemanticNode source, Symbol_Type newType) {
		super(newType);
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
