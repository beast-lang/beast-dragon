module beast.corelib.type.bool_;

import beast.corelib.type.toolkit;

void initialize_Bool( ref CoreLibrary_Types tp ) {
	Symbol[ ] sym;

	// Implicit constructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp.Bool, tp.Void, //
			ExpandedFunctionParameter.bootstrap( ), //
			BackendPrimitiveOperation.boolCtor //
			 );

	// Copy constructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp.Bool, tp.Void, //
			ExpandedFunctionParameter.bootstrap( enm.xxctor.copy, tp.Bool ), //
			BackendPrimitiveOperation.boolCopyCtor //
			 );

	// Assign constructor
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp.Bool, tp.Void, //
			ExpandedFunctionParameter.bootstrap( enm.xxctor.opAssign, tp.Bool ), //
			BackendPrimitiveOperation.boolCopyCtor //
			 );

	// Operator overloads

	// ||
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#operator", tp.Bool, tp.Bool, //
			ExpandedFunctionParameter.bootstrap( enm.operator.binOr, tp.Bool ), //
			BackendPrimitiveOperation.boolOr //
			 );

	// &&
	sym ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#operator", tp.Bool, tp.Bool, //
			ExpandedFunctionParameter.bootstrap( enm.operator.binAnd, tp.Bool ), //
			BackendPrimitiveOperation.boolAnd //
			 );

	tp.Bool.initialize( sym );
}
