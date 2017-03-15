module beast.corelib.type.toolkit;

public {
	import beast.backend.common.primitiveop : BackendPrimitiveOperation;
	import beast.code.data.codenamespace.bootstrap : BootstrapNamespace;
	import beast.code.data.codenamespace.namespace : Namespace;
	import beast.code.data.function_.btspmemrt : Symbol_BootstrapMemberRuntimeFunction;
	import beast.code.data.function_.expandedparameter : ExpandedFunctionParameter;
	import beast.code.data.function_.primmemrt : Symbol_PrimitiveMemberRuntimeFunction;
	import beast.code.data.type.btspstcclass : Symbol_BootstrapStaticClass;
	import beast.corelib.toolkit;
	import beast.corelib.type.types : CoreLibrary_Types;
}

import beast.corelib.const_.enums;

ref CoreLibrary_Enums enm( ) {
	return coreLibrary.enum_;
}
