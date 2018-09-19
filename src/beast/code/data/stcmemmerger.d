module beast.code.data.stcmemmerger.d;

import beast.code.ast.node;
import beast.code.data.symbol;

/// When a codebuilding for a runtime function is run multiple times, it is necessary that static variable declarations represent the same symbols
/// The merging is searched via CodeLocation (bootstrap static members are to be handled by the programmer)
final class StaticMemberMerger {

public:
	bool isFinished() {
		return isFinished_;
	}

public:
	void addRecord(AST_Node ast, Symbol sym) {
		assert(!isFinished_);
		assert(ast !in members_);

		members_[ast] = sym;
	}

	Symbol getRecord(AST_Node ast) {
		assert(isFinished_);
		assert(ast in members_);

		return members_[ast];
	}

	void finish() {
		assert(!isFinished_);
		isFinished_ = true;
	}

private:
	Symbol[AST_Node] members_;

	bool isFinished_;

}
