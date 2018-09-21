module beast.corelib.deco.functions;

import beast.corelib.toolkit;
import beast.corelib.deco.static_;
import beast.code.semantic.function_.function_;
import beast.code.semantic.function_.primstcrt;
import beast.code.semantic.function_.expandedparameter;
import beast.backend.common.primitiveop;
import beast.code.semantic.var.tmplocal;

struct CoreLibrary_Functions {

public:
	Symbol_Function printBool, printInt;

	Symbol_Function malloc, free;

	Symbol_Function assert_;

public:
	void initialize(void delegate(Symbol) sink, DataEntity parent) {
		sink(printBool = new Symbol_PrimitiveStaticRuntimeFunction(ID!"print", parent, //
				coreType.Void, ExpandedFunctionParameter.bootstrap(coreType.Bool), //
				(cb, args) { //
					cb.build_primitiveOperation(BackendPrimitiveOperation.print, args[0]);
				}));
		sink(printInt = new Symbol_PrimitiveStaticRuntimeFunction(ID!"print", parent, //
				coreType.Void, ExpandedFunctionParameter.bootstrap(coreType.Int32), //
				(cb, args) { //
					cb.build_primitiveOperation(BackendPrimitiveOperation.print, args[0]);
				}));
		sink(printInt = new Symbol_PrimitiveStaticRuntimeFunction(ID!"print", parent, //
				coreType.Void, ExpandedFunctionParameter.bootstrap(coreType.Int64), //
				(cb, args) { //
					cb.build_primitiveOperation(BackendPrimitiveOperation.print, args[0]);
				}));

		sink(malloc = new Symbol_PrimitiveStaticRuntimeFunction(ID!"malloc", parent, //
				coreType.Pointer, ExpandedFunctionParameter.bootstrap(coreType.Size), //
				(cb, args) { //
					auto result = new DataEntity_TmpLocalVariable(coreType.Pointer);
					cb.build_localVariableDefinition(result);
					cb.build_primitiveOperation(BackendPrimitiveOperation.markPtr, result);
					cb.build_primitiveOperation(BackendPrimitiveOperation.malloc, result, args[0]);

					// Result data
					result.buildCode(cb);
				}));
		sink(free = new Symbol_PrimitiveStaticRuntimeFunction(ID!"free", parent, //
				coreType.Void, ExpandedFunctionParameter.bootstrap(coreType.Pointer), //
				(cb, args) { //
					cb.build_primitiveOperation(BackendPrimitiveOperation.free, args[0]);
				}));

		sink(assert_ = new Symbol_PrimitiveStaticRuntimeFunction(ID!"assert", parent, //
				coreType.Void, ExpandedFunctionParameter.bootstrap(coreType.Bool), //
				(cb, args) { //
					cb.build_primitiveOperation(BackendPrimitiveOperation.assert_, args[0]);
				}));
	}
}
