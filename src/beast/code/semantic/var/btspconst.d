module beast.code.semantic.var.btspconst;

import beast.code.semantic.toolkit;
import beast.code.semantic.var.static_;
import beast.code.semantic.util.subst;

final class Symbol_BootstrapConstant : Symbol_StaticVariable {

public:
	/// Length of the data is inferred from the dataType instance size
	this(DataEntity parent, Identifier identifier, Symbol_Type dataType, ulong data) {
		super(parent);
		assert(dataType.instanceSize <= data.sizeof);

		dataType_ = dataType;
		identififer_ = identifier;

		with (memoryManager.session(SessionPolicy.doNotWatchCtChanges)) {
			auto block = memoryManager.allocBlock(dataType.instanceSize, MemoryBlock.Flag.ctime);
			block.markDoNotGCAtSessionEnd();
			block.identifier = identifier.str;
			block.relatedDataEntity = dataEntity;

			assert(data.sizeof >= dataType.instanceSize);
			memoryPtr_ = block.startPtr.write(&data, dataType.instanceSize);
		}
	}

	/// Creates a constant by copying data from given data entity (at ctime)
	this(DataEntity parent, Identifier identifier, DataEntity copyCtorSource) {
		super(parent);

		identififer_ = identifier;

		with (memoryManager.session(SessionPolicy.doNotWatchCtChanges)) {
			dataType_ = copyCtorSource.dataType;

			auto block = memoryManager.allocBlock(dataType.instanceSize, MemoryBlock.Flag.ctime);
			block.markDoNotGCAtSessionEnd();
			block.identifier = identifier.str;
			block.relatedDataEntity = dataEntity;

			scope cb = new CodeBuilder_Ctime();
			cb.build_copyCtor(new SubstitutiveDataEntity(block.startPtr, dataType), copyCtorSource);
			cb.result.destroy();

			memoryPtr_ = block.startPtr;
		}
	}

public:
	override Identifier identifier() {
		return identififer_;
	}

	override Symbol_Type dataType() {
		return dataType_;
	}

	override MemoryPtr memoryPtr() {
		return memoryPtr_;
	}

	override bool isCtime() {
		return true;
	}

protected:
	Symbol_Type dataType_;
	Identifier identififer_;
	MemoryPtr memoryPtr_;

}
