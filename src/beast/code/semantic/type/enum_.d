module beast.code.semantic.type.enum_;

import beast.code.semantic.toolkit;
import beast.code.semantic.type.stcclass;
import beast.code.semantic.util.reinterpret;
import beast.code.semantic.function_.primmemrt;
import beast.code.semantic.function_.expandedparameter;
import beast.code.semantic.type.stcclass;

abstract class Symbol_Enum : Symbol_Type {
	mixin TaskGuard!"valueAAGeneration";

public:
	this(DataEntity parent, Symbol_StaticClass baseClass) {
		staticData_ = new Data(this, MatchLevel.fullMatch);
		parent_ = parent;
		baseClass_ = baseClass;
	}

	protected override void _initialize(void delegate(Symbol) sink) {
		sink(new Symbol_PrimitiveMemberRuntimeFunction(ID!"#explicitCast", this, baseClass, //
				ExpandedFunctionParameter.bootstrap(baseClass.dataEntity), //
				(cb, inst, args) { //
					inst.reinterpret(baseClass).buildCode(cb);
				}));
	}

public:
	final override DeclType declarationType() {
		return DeclType.enum_;
	}

	/// Class the enum is based on
	final Symbol_StaticClass baseClass() {
		return baseClass_;
	}

	final override size_t instanceSize() {
		return baseClass_.instanceSize;
	}

	override string valueIdentificationString(MemoryPtr value) {
		if (instanceSize > 4)
			return baseClass_.valueIdentificationString(value);

		enforceDone_valueAAGeneration();
		if (auto sym = readToUint(value) in valueAAWIP_)
			return ":%s".format(sym.identifier.str);

		return baseClass_.valueIdentificationString(value);
	}

public:
	final override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null) {
		if (matchLevel != MatchLevel.fullMatch)
			return new Data(this, matchLevel);
		else
			return staticData_;
	}

protected:
	override Overloadset _resolveIdentifier_mid(Identifier id, DataEntity instance, MatchLevel matchLevel) {
		if (instance)
			return baseClass_.tryResolveIdentifier(id, new DataEntity_ReinterpretCast(instance, baseClass_, MatchLevel.fullMatch), matchLevel | MatchLevel.baseClass);
		else
			return baseClass_.tryResolveIdentifier(id, null);
	}

private:
	final void execute_valueAAGeneration() {
		auto instSize = instanceSize;

		if (instSize > 4)
			return;

		foreach (mem; namespace.members) {
			if (mem.declarationType != Symbol.DeclType.staticVariable || !mem.identifier)
				continue;

			DataEntity entity = mem.dataEntity;

			if (!entity.isCtime || entity.dataType !is this)
				continue;

			auto ctexec = entity.ctExec;
			valueAAWIP_[readToUint(ctexec.value)] = mem;
			ctexec.destroy();
		}
	}

	final uint readToUint(MemoryPtr ptr) {
		switch (instanceSize) {

		case 1:
			return ptr.readPrimitive!ubyte();

		case 2:
			return ptr.readPrimitive!ushort();

		case 3:
			assert(0, "Enum type instance size not power of two (3)");

		case 4:
			return ptr.readPrimitive!uint();

		default:
			assert(0);

		}
	}

protected:
	Symbol_StaticClass baseClass_;

private:
	DataEntity staticData_;
	DataEntity parent_;
	Symbol[uint] valueAAWIP_;

private:
	final static class Data : typeof(super).Data {

	public:
		this(Symbol_Enum sym, MatchLevel matchLevel) {
			super(sym, matchLevel);

			sym_ = sym;
		}

	public:
		override DataEntity parent() {
			return sym_.parent_;
		}

	private:
		Symbol_Enum sym_;

	}

}
