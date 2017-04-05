module beast.corelib.type.int_;

import beast.corelib.type.toolkit;

void initialize_Int( Symbol_BootstrapStaticClass tp, ref CoreLibrary_Types tps ) {
	Symbol[ ] mem;

	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCtor( tp ); // Implicit constructor
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCopyCtor( tp ); // Copy constructor
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newNoopDtor( tp ); // Destructor

	// Operator overloads
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveAssignOp( tp ); // a = b
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveEqNeqOp( tp ); // a == b, a != b

	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( tp, tps.Bool, coreLibrary.enum_.operator.binGt, BackendPrimitiveOperation.intGt ); // a > b
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( tp, tps.Bool, coreLibrary.enum_.operator.binGte, BackendPrimitiveOperation.intGte ); // a >= b
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( tp, tps.Bool, coreLibrary.enum_.operator.binLt, BackendPrimitiveOperation.intLt ); // a < b
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( tp, tps.Bool, coreLibrary.enum_.operator.binLte, BackendPrimitiveOperation.intLte ); // a <= b

	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( tp, coreLibrary.enum_.operator.binPlus, BackendPrimitiveOperation.intAdd ); // a + b
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( tp, coreLibrary.enum_.operator.binMinus, BackendPrimitiveOperation.intSub ); // a - b
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( tp, coreLibrary.enum_.operator.binMult, BackendPrimitiveOperation.intMult ); // a * b
	mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( tp, coreLibrary.enum_.operator.binDiv, BackendPrimitiveOperation.intDiv ); // a / b

	tp.valueIdentificationStringFunc = ( ptr ) { return ptr.readPrimitive!int.to!string; };
	tp.initialize( mem );
}
