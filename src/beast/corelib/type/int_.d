module beast.corelib.type.int_;

import beast.corelib.type.toolkit;

void initialize_Int( ref CoreLibrary_Types tp ) {
	Symbol[ ] mem;

	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCtor( tp.Int ); // Implicit constructor
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCopyCtor( tp.Int ); // Copy constructor
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newNoopDtor( tp.Int ); // Destructor

	// Operator overloads
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveAssignOp( tp.Int ); // a = b

	tp.Int.valueIdentificationStringFunc = ( ptr ) { return ptr.readPrimitive!int.to!string; };
	tp.Int.initialize( mem );
}
