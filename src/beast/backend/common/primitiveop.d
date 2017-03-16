module beast.backend.common.primitiveop;

/// Primitive operations are functions that are actually not functions but somehow instruction primites defined directly in the backend
enum BackendPrimitiveOperation {

	// General
	noopDtor, /// Destructor that does nothing (has separate primitive op for debugging purposes)

	// BOOL ops
	boolCtor, /// initalizes to false
	boolCopyCtor,
	boolOr,
	boolAnd,

	// INT ops
	intCtor, /// initializes to 0
	intCopyCtor,

}