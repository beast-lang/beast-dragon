module beast.code.entity.var.local;

import beast.code.entity.toolkit;

abstract class DataEntity_LocalVariable : DataEntity {
	mixin TaskGuard!"outerHashObtaining";

public:
	this(Symbol_Type dataType) {
		super(MatchLevel.fullMatch);

		assert(dataType.instanceSize != 0, "DataType %s instanceSize 0".format(dataType.identificationString));
		assert(currentScope, "Initializing local variable outside scope");

		dataType_ = dataType;
		scope__ = currentScope;

		assert(parent);
		assert(dataType);

		debug assert(context.jobId == scope__.jobId);
	}

public:
	final override Symbol_Type dataType() {
		return dataType_;
	}

	final override bool isCtime() {
		assert(memoryBlock_, "Memory not yet allocated");
		return memoryBlock_.isCtime;
	}

	final MemoryPtr memoryPtr() {
		assert(memoryBlock_, "Memory not yet allocated");
		return memoryBlock_.startPtr;
	}

	final MemoryBlock memoryBlock() {
		assert(memoryBlock_, "Memory not yet allocated");
		return memoryBlock_;
	}

	final override DataEntity parent() {
		return scope__.parentEntity();
	}

	override final Hash outerHash() {
		enforceDone_outerHashObtaining();
		return outerHashWIP_;
	}

	override string identificationString() {
		return "%s%s %s".format(isCtime ? "@ctime " : null, dataType.tryGetIdentificationString, identificationString_noPrefix);
	}

	override void buildCode(CodeBuilder cb) {
		cb.build_memoryAccess(memoryPtr);
	}

public:
	void allocate(bool isCtime) {
		allocate_(isCtime, MemoryBlock.Flag.noFlag);
	}

public:
	/// Return data entity representing copy constructor call for given variable
	static DataEntity getCopyCtor(DataEntity variable, DataEntity initValue) {
		// We don't call var.resolveIdentifier because of Type variables
		// calling var.resolveIdentifier would result in calling #ctor of the represented type
		return variable.dataType.expectResolveIdentifier_direct(ID!"#ctor", variable).resolveCall(variable.ast, true, initValue);
	}

	/// Return data entity representing copy constructor call for given variable
	final DataEntity getCopyCtor(DataEntity initValue) {
		return getCopyCtor(this, initValue);
	}

protected:
	/// Allocates memory for the variable (this is called in CodeBuilder.build_localVariableDefinition)
	final pragma(inline) void allocate_(bool isCtime, MemoryBlock.Flags additionalMemoryBlockFlags) {
		assert(!memoryBlock_, "Already allocated");

		memoryBlock_ = memoryManager.allocBlock(dataType_.instanceSize, MemoryBlock.Flag.local | additionalMemoryBlockFlags | (isCtime ? MemoryBlock.Flag.ctime : MemoryBlock.Flags.noFlag));
		memoryBlock_.relatedDataEntity = this;
	}

protected:
	Symbol_Type dataType_;
	DataScope scope__;
	MemoryBlock memoryBlock_;
	Hash outerHashWIP_;

private:
	void execute_outerHashObtaining() {
		// TODO: hashing this pointer is horrible
		outerHashWIP_ = parent.outerHash + (identifier ? identifier.hash : Hash(cast(size_t) cast(void*) this));
	}

}
