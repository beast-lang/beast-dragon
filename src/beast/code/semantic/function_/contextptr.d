module beast.code.semantic.function_.contextptr;

import beast.code.semantic.toolkit;
import beast.code.semantic.var.local;

final class DataEntity_ContextPointer : DataEntity {

public:
	this(Identifier identifier, Symbol_Type dataType, bool isCtime) {
		super(MatchLevel.fullMatch);

		identifier_ = identifier;
		dataType_ = dataType;
		isCtime_ = isCtime;
		inst_ = dataType.dataEntity(MatchLevel.fullMatch, this);
	}

public:
	override Symbol_Type dataType() {
		return dataType_;
	}

	override DataEntity parent() {
		return inst_;
	}

	override bool isCtime() {
		return isCtime_;
	}

	override Identifier identifier() {
		return identifier_;
	}

	override AST_Node ast() {
		return null;
	}

public:
	override void buildCode(CodeBuilder cb) {
		cb.build_contextPtrAccess();
	}

private:
	Identifier identifier_;
	Symbol_Type dataType_;
	bool isCtime_;
	DataEntity inst_;

}
