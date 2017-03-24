module beast.corelib.type.bool_;

import beast.corelib.type.toolkit;

void initialize_Bool( ref CoreLibrary_Types tp ) {
	Symbol[ ] sym;

	// Implicit constructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp.Bool, tp.Void, //
			ExpandedFunctionParameter.bootstrap( ), //
			BackendPrimitiveOperation.memZero );

	// Copy/assign constructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp.Bool, tp.Void, //
			ExpandedFunctionParameter.bootstrap( enm.xxctor.opAssign, tp.Bool ), //
			BackendPrimitiveOperation.memCpy );

	// Destructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", tp.Bool, tp.Void, //
			ExpandedFunctionParameter.bootstrap( ), //
			BackendPrimitiveOperation.noopDtor );

	// Operator overloads

	// a = b
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#operator", tp.Bool, tp.Void, //
			ExpandedFunctionParameter.bootstrap( enm.operator.assign, tp.Bool ), //
			BackendPrimitiveOperation.memCpy );

	// a || b
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#operator", tp.Bool, tp.Bool, //
			ExpandedFunctionParameter.bootstrap( enm.operator.binOr, tp.Bool ), //
			BackendPrimitiveOperation.boolOr );

	// a && b
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#operator", tp.Bool, tp.Bool, //
			ExpandedFunctionParameter.bootstrap( enm.operator.binAnd, tp.Bool ), //
			BackendPrimitiveOperation.boolAnd );

	tp.Bool.valueIdentificationStringFunc = ( ptr ) { return ptr.readPrimitive!bool ? "true" : "false"; };
	tp.Bool.initialize( sym );
}
