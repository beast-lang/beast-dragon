module beast.backend.common.primitiveop;

/// Primitive operations are functions that are actually not functions but somehow instruction primites defined directly in the backend
enum BackendPrimitiveOperation {

	// General
	memZero, /// Initializes given variable to zeros (considers var.dataType.instanceSize)
	memCpy, /// Performs a bit copy (considers var.dataType.instanceSize)
	noopDtor, /// Destructor that does nothing (has separate primitive op for debugging purposes)
	print, /// Prints given variable to console
	assert_, /// Operand must be true or throws an error

	// BOOL ops
	boolOr,
	boolAnd,

	// INT ops

	// REREFERENCE/POINTER ops
	refRefCtor, /// Initializes to reference of value

}