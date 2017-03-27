module beast.backend.common.primitiveop;

/// Primitive operations are functions that are actually not functions but somehow instruction primites defined directly in the backend
enum BackendPrimitiveOperation {

	// General
	memZero, /// (argT, arg1) Set given variable to zeros (considers argT.instanceSize)
	memCpy, /// (argT, arg2 > rag1) Perform a bit copy (considers argT.instanceSize)
	noopDtor, /// () Destructor that does nothing (has separate primitive op for debugging purposes)
	print, /// (argT, arg0) Print given variable to console
	assert_, /// (arg0) Operand must be true or throws an error

	// BOOL ops

	// INT ops

	// REREFERENCE/POINTER ops
	getAddr, /// (&arg2 > arg1) Stores reference (pointer) to given expression into given variable
	dereference, /// (*arg1) Returns (reference to) data referenced by given variable


}