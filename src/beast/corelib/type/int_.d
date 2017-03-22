module beast.corelib.type.int_;

import beast.corelib.type.toolkit;

void initialize_Int( ref CoreLibrary_Types tp ) {
	Symbol[ ] sym;

	// Implicit constructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp.Int, tp.Void, //
			ExpandedFunctionParameter.bootstrap( ), //
			BackendPrimitiveOperation.zeroInitCtor );

	// Copy/assign constructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp.Int, tp.Void, //
			ExpandedFunctionParameter.bootstrap( enm.xxctor.opAssign, tp.Int ), //
			BackendPrimitiveOperation.primitiveCopyCtor );

	// Destructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", tp.Int, tp.Void, //
			ExpandedFunctionParameter.bootstrap( ), //
			BackendPrimitiveOperation.noopDtor );

	// Operator overloads

	tp.Int.valueIdentificationStringFunc = ( ptr ) { return ptr.readPrimitive!int.to!string; };
	tp.Int.initialize( sym );
}
