module beast.code.entity.util.btsp;

import beast.code.entity.toolkit;
import beast.code.entity.decorator.decorator;
import beast.code.entity.callable.match;

/// Data entity whose parameters are passed in the constructor
final class DataEntity_Bootstrap : DataEntity {

public:
	alias BuildCodeFunc = void delegate(CodeBuilder cb);

public:
	this(Identifier identifier, Symbol_Type dataType, DataEntity parent, bool isCtime, BuildCodeFunc buildCodeFunc, MatchLevel matchLevel = MatchLevel.fullMatch) {
		super(matchLevel);

		dataType_ = dataType;
		parent_ = parent;
		isCtime_ = isCtime;
		buildCodeFunc_ = buildCodeFunc;
		identifier_ = identifier;
	}

public:
	override Symbol_Type dataType() {
		return dataType_;
	}

	override DataEntity parent() {
		return parent_;
	}

	override bool isCtime() {
		return isCtime_;
	}

	override void buildCode(CodeBuilder cb) {
		buildCodeFunc_(cb);
	}

public:
	override Identifier identifier() {
		return identifier_;
	}

	override AST_Node ast() {
		return null;
	}

	override Hash outerHash() {
		return Hash(0);
	}

protected:
	DataEntity parent_;
	BuildCodeFunc buildCodeFunc_;
	Symbol_Type dataType_;
	Identifier identifier_;
	bool isCtime_;

}
