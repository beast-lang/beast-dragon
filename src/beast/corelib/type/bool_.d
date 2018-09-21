module beast.corelib.type.bool_;

import beast.corelib.type.toolkit;
import beast.code.semantic.var.tmplocal;

void initialize_Bool(ref CoreLibrary_Types tp) {
	Symbol[] mem;

	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCtor(tp.Bool); // Implicit constructor
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCopyCtor(tp.Bool); // Copy constructor
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newNoopDtor(tp.Bool); // Destructor

	// Operator overloads
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveAssignOp(tp.Bool); // a = b
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveEqNeqOp(tp.Bool); // a == b, a != b

	// a || b
	mem ~= new Symbol_PrimitiveMemberRuntimeFunction(ID!"#opBinary", tp.Bool, tp.Bool, //
			ExpandedFunctionParameter.bootstrap(enm.operator.binOr, tp.Bool), //
			(cb, inst, args) { //
				auto var = new DataEntity_TmpLocalVariable(coreType.Bool);
				cb.build_localVariableDefinition(var);

				// We construct the local variable based on the if result
				cb.build_if(inst, //
					&var.expectResolveIdentifier(ID!"#ctor").resolveCall(null, true, coreConst.true_.dataEntity).buildCode, //
					&var.expectResolveIdentifier(ID!"#ctor").resolveCall(null, true, args[0]).buildCode);

				// Result expression is var
				var.buildCode(cb);
			});

	// a && b
	mem ~= new Symbol_PrimitiveMemberRuntimeFunction(ID!"#opBinary", tp.Bool, tp.Bool, //
			ExpandedFunctionParameter.bootstrap(enm.operator.binAnd, tp.Bool), //
			(cb, inst, args) { //
				auto var = new DataEntity_TmpLocalVariable(coreType.Bool);
				cb.build_localVariableDefinition(var);

				// We construct the local variable based on the if result
				cb.build_if(inst, //
					&var.expectResolveIdentifier(ID!"#ctor").resolveCall(null, true, args[0]).buildCode, //
					&var.expectResolveIdentifier(ID!"#ctor").resolveCall(null, true, coreConst.false_.dataEntity).buildCode);

				// Result expression is var
				var.buildCode(cb);
			});

	// !a
	mem ~= new Symbol_PrimitiveMemberRuntimeFunction(ID!"#opPrefix", tp.Bool, tp.Bool, //
			ExpandedFunctionParameter.bootstrap(enm.operator.preNot), //
			(cb, inst, args) { //
				/// args[ 0 ] is Operator.binAnd

				auto var = new DataEntity_TmpLocalVariable(coreType.Bool);
				cb.build_localVariableDefinition(var);
				cb.build_primitiveOperation(BackendPrimitiveOperation.boolNot, var, inst);

				// Result expression is var
				var.buildCode(cb);
			});

	tp.Bool.valueIdentificationStringFunc = (ptr) { return ptr.readPrimitive!bool ? "true" : "false"; };
	tp.Bool.initialize(mem);
}
