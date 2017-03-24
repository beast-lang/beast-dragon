module beast.backend.common.primitiveop;

/// Primitive operations are functions that are actually not functions but somehow instruction primites defined directly in the backend
enum BackendPrimitiveOperation {

	// General
	zeroInitCtor, /// Initializes to zeros
	primitiveCopyCtor, /// Performs a bit copy
	noopDtor, /// Destructor that does nothing (has separate primitive op for debugging purposes)
	print, /// Prints given variable to console

	// BOOL ops
	boolOr,
	boolAnd,

	// INT ops

	// REREFERENCE/POINTER ops
	refRefCtor, /// Initializes to reference of value

}