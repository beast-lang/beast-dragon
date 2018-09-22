module beast.code.semantic.symbol;

import beast.code.semantic.toolkit;
import beast.code.semantic.var.mem;

/// Declaration of something (not really explaining, I know)
abstract class Symbol : SemanticNode {
	mixin TaskGuard!"outerHashObtaining";

public:
	enum DeclType {
		staticVariable,
		memberVariable,
		staticFunction,
		memberFunction,
		staticClass,
		memberClass,
		enum_, // enum is always static
		decorator,
		alias_,
		module_
	}

public:
	/// Type of the declaration
	abstract DeclType declarationType();

	/// Outer hash - hash that is generated based on entity declaration and surroundings, not its definition (considering classes, functions, etc)
	final Hash outerHash() {
		enforceDone_outerHashObtaining();
		return outerHashWIP_;
	}

public:
	Symbol_MemberVariable isMemberVariable() {
		return null;
	}

protected:
	Hash outerHashWIP_;

protected:
	void execute_outerHashObtaining() {
		outerHashWIP_ = identifier.hash;

		if (auto parent = dataEntity.parent)
			outerHashWIP_ += parent.outerHash;
	}

}