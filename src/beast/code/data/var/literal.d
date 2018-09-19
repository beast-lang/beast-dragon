module beast.code.data.var.literal;

import beast.code.data.toolkit;
import beast.code.data.var.static_;

final class Symbol_Literal : Symbol_StaticVariable {

public:
	/// Length of the data is inferred from the dataType instance size
	this(Symbol_Type dataType, const ubyte[] data, string identifier = null) {
		super(null);
		assert(dataType.instanceSize == data.length);

		dataType_ = dataType;

		with (memoryManager.session(SessionPolicy.doNotWatchCtChanges)) {
			auto block = memoryManager.allocBlock(dataType.instanceSize, MemoryBlock.Flag.ctime);
			id_ = Identifier(identifier ? identifier : "lit_%#x".format(block.startPtr.val));

			block.markDoNotGCAtSessionEnd();
			block.identifier = id_.str;
			block.relatedDataEntity = dataEntity;

			memoryPtr_ = block.startPtr.write(data);
		}
	}

public:
	override Identifier identifier() {
		return id_;
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
	Identifier id_;
	Symbol_Type dataType_;
	MemoryPtr memoryPtr_;

}
