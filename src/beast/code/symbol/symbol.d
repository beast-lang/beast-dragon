module beast.code.symbol.symbol;

import beast.code.entity.toolkit;
import beast.util.identifiable;
import beast.core.project.codelocation;
import beast.util.hash;
import beast.code.entity.var.mem;

/// Declaration of something (not really explaining, I know)
abstract class Symbol : Identifiable {
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
	/// Identifier of the declaration; can be null
	abstract Identifier identifier();

	/// Parent of this symbol
	abstract Symbol parent();

	/// Type of the declaration
	abstract DeclType declarationType();

	/// AST node related to the declaration; can be null
	AST_Node ast() {
		return null;
	}

	override string str(ToStringFlags flags = 0) {
		assert(identifier, "Symbol without identifier");

		if (parent)
			return "%s.%s".format(parent.str(ToString.symbolParentMask), identifier);
		else
			return identifier.str;
	}

	/// Location of where in the code the symbol was declared (or code that +- matches it)
	final CodeLocation codeLocation() {
		return ast ? ast.codeLocation : cast(CodeLocation) null;
	}

	/// Outer hash - hash that is generated based on entity declaration and surroundings, not its definition (considering classes, functions, etc)
	final Hash outerHash() {
		enforceDone_outerHashObtaining();
		return outerHashWIP_;
	}

public:
	/// Data entity representing the symbol, either with static static access or via instance of parent type
	DataEntity dataEntity(DataEntity parentInstance = null, MatchLevel matchLevel = MatchLevel.fullMatch) {
		return new SymbolDataEntity(this, parentInstance, matchLevel);
	}

	void overloadset(ref Overloadset overloadset, DataEntity parentInstance = null, MatchLevel matchLevel = MatchLevel.fullMatch) {
		overloadset ~= dataEntity(parentInstance, matchLevel);
	}

	bool resolveIdentifier(ref Overloadset overloadset, ResolutionFlags flags = ResolutionFlag.defaultFlags, DataEntity instance = null, MatchLevel matchLevel = MatchLevel.fullMatch) {

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

final class SymbolDataEntity : DataEntity {

public:
	this(DataEntity parentInstance, Symbol symbol, MatchLevel matchLevel) {
		assert(symbol);

		super(matchLevel);
		parentInstance_ = parentInstance;
		symbol_ = symbol;
	}

public:
	override Identifier identifier() {
		return symbol_.identifier;
	}

	override AST_Node ast() {
		return symbol_.ast;
	}

private:
	Symbol symbol_;
	DataEntity parentInstance_;

}
