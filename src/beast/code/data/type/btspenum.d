module beast.code.data.type.btspenum;

import beast.code.data.toolkit;
import beast.code.data.codenamespace.namespace;
import beast.code.data.codenamespace.bootstrap;
import beast.code.data.type.enum_;
import beast.code.data.type.stcclass;
import beast.code.data.function_.primmemrt;
import beast.code.data.function_.expandedparameter;
import beast.backend.common.primitiveop;
import beast.code.data.alias_.btsp;

final class Symbol_BootstrapEnum : Symbol_Enum {

public:
	this(DataEntity parent, Identifier identifier, Symbol_StaticClass baseClass) {
		// This code must be before super call, as super constructor calls identifier
		identifier_ = identifier;

		super(parent, baseClass);
		assert(identifier);

		namespace_ = new BootstrapNamespace(this);
	}

	void initialize(Symbol[] members) {
		super.initialize();

		members ~= new Symbol_BootstrapAlias(ID!"#dtor", (matchLevel, parentInstance) => baseClass.tryResolveIdentifier(ID!"#dtor", parentInstance.reinterpret(baseClass), matchLevel));

		// Copy/assign constructor
		members ~= new Symbol_PrimitiveMemberRuntimeFunction(ID!"#ctor", this, coreType.Void, //
				ExpandedFunctionParameter.bootstrap(this), //
				(cb, inst, args) { //
					baseClass.expectResolveIdentifier(ID!"#ctor", inst.reinterpret(baseClass)).resolveCall(null, true, args[0].reinterpret(baseClass)).buildCode(cb);
				});

		namespace_.initialize(members);
	}

public:
	override Identifier identifier() {
		return identifier_;
	}

	override Namespace namespace() {
		return namespace_;
	}

private:
	BootstrapNamespace namespace_;
	Identifier identifier_;

}
