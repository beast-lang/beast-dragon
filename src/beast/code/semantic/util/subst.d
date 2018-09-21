module beast.code.semantic.util.subst;

import beast.code.semantic.toolkit;

/// Simple data entity that represents a memory pointer at compile time
final class SubstitutiveDataEntity : DataEntity {

public:
	this(MemoryPtr ptr, Symbol_Type type) {
		super(MatchLevel.fullMatch);

		ptr_ = ptr;
		type_ = type;
	}

public:
	override Symbol_Type dataType() {
		return type_;
	}

	override bool isCtime() {
		return true;
	}

public:
	override DataEntity parent() {
		return null;
	}

	override AST_Node ast() {
		return null;
	}

public:
	override void buildCode(CodeBuilder cb) {
		auto _gd = ErrorGuard(this);

		cb.build_memoryAccess(ptr_);
	}

private:
	MemoryPtr ptr_;
	Symbol_Type type_;

}
