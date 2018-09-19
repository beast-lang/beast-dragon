module beast.code.data.type.btspstcclass;

import beast.code.data.toolkit;
import beast.code.data.type.stcclass;
import beast.code.data.codenamespace.namespace;
import beast.code.data.codenamespace.bootstrap;

final class Symbol_BootstrapStaticClass : Symbol_StaticClass {

public:
	this(DataEntity parent, Identifier identifier, size_t instanceSize) {
		// This code must be before super call, as super constructor calls identifier
		identifier_ = identifier;
		instanceSize_ = instanceSize;

		super(parent);
		assert(identifier);

		namespace_ = new BootstrapNamespace(this);
		valueIdentificationStringFunc_ = &super.valueIdentificationString;
	}

	void initialize(Symbol[] members) {
		super.initialize();
		namespace_.initialize(members);
	}

public:
	void valueIdentificationStringFunc(string delegate(MemoryPtr) func) {
		debug assert(!initialized_);
		valueIdentificationStringFunc_ = func;
	}

public:
	override Identifier identifier() {
		return identifier_;
	}

	override size_t instanceSize() {
		return instanceSize_;
	}

	override Namespace namespace() {
		return namespace_;
	}

	override string valueIdentificationString(MemoryPtr value) {
		return valueIdentificationStringFunc_(value);
	}

private:
	BootstrapNamespace namespace_;
	Identifier identifier_;
	size_t instanceSize_;
	string delegate(MemoryPtr) valueIdentificationStringFunc_;

}
