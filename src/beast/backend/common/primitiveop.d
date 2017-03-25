module beast.backend.common.primitiveop;

/// Primitive operations are functions that are actually not functions but somehow instruction primites defined directly in the backend
enum BackendPrimitiveOperation {

	// General
	memZero, /// (inst) Set given variable to zeros (considers var.dataType.instanceSize)
	memCpy, /// (arg[1] -> inst) Perform a bit copy (considers var.dataType.instanceSize)
	noopDtor, /// () Destructor that does nothing (has separate primitive op for debugging purposes)
	print, /// (arg[0]) Print given variable to console
	assert_, /// (arg[0]) Operand must be true or throws an error

	// BOOL ops
	boolOr, // (inst, arg[1])
	boolAnd, // (inst, arg[1])

	// INT ops

	// REREFERENCE/POINTER ops
	storeAddr, /// (inst, arg1) Set variable to address of instance
	loadAddr, /// (inst -> result) 'Dereferences' given address - returns reference to the addressed object


}