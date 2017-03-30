module beast.backend.common.primitiveop;

/// Primitive operations are functions that are actually not functions but somehow instruction primites defined directly in the backend
enum BackendPrimitiveOperation {

	// General
	memZero, /// (argT, arg1) Set given variable to zeros (considers argT.instanceSize)
	memCpy, /// (argT, arg2 > arg1) Perform a bit copy (considers argT.instanceSize)
	memEq, /// (argT, arg2 == arg3 > arg1) Performs bit comparison of two operands and returns if they equal
	memNeq, /// (argT, arg2 != arg3 > arg1) Performs bit comparison of two operands and returns if they equal
	noopDtor, /// () Destructor that does nothing (has separate primitive op for debugging purposes)
	print, /// (argT, arg0) Print given variable to console
	assert_, /// (arg0) Operand must be true or throws an error

	// BOOL ops
	boolNot, /// (arg2 > arg1) Perform a boolean inversion

	// INT ops
	intAdd, /// (arg2 + arg3 => arg1, considers argT.instanceSize)
	intSub, /// (arg2 - arg3 => arg1, considers argT.instanceSize)
	intMult, /// (arg2 * arg3 => arg1, considers argT.instanceSize)
	intDiv, /// (arg2 / arg3 => arg1, considers argT.instanceSize)
	intGt, /// (arg2 > arg3 => arg1)
	intGte, /// (arg2 >= arg3 => arg1)
	intLt, /// (arg2 < arg3 => arg1)
	intLte, /// (arg2 <= arg3 => arg1)

	// REREFERENCE/POINTER ops
	markPtr, /// (arg1) Marks given memory as a pointer (used for compile-time stuff)
	unmarkPtr, /// (arg1) Unmarks given memory as a pointer
	getAddr, /// (&arg2 > arg1) Stores reference (pointer) to given expression into given variable
	dereference, /// (*arg1) Returns (reference to) data referenced by given variable

}
