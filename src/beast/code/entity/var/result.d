module beast.code.entity.var.result;

import beast.code.entity.toolkit;
import beast.code.entity.var.local;
import beast.code.entity.function_.rt;

/// Data entity representing function return value
final class DataEntity_Result : DataEntity {

public:
	this(Symbol_RuntimeFunction func, bool isCtime, Symbol_Type dataType) {
		super(MatchLevel.fullMatch);

		isCtime_ = isCtime;
		dataType_ = dataType;
		func_ = func;
	}

public:
	override Symbol_Type dataType() {
		return dataType_;
	}

	override bool isCtime() {
		return isCtime_;
	}

	override Identifier identifier() {
		return null;
	}

	override DataEntity parent() {
		return func_.dataEntity;
	}

	override AST_Node ast() {
		return null;
	}

	override void buildCode(CodeBuilder cb) {
		cb.build_functionResultAccess(func_);
	}

private:
	Symbol_RuntimeFunction func_;
	Symbol_Type dataType_;
	bool isCtime_;

}
