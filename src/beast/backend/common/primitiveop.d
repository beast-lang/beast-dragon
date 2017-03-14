module beast.backend.common.primitiveop;

/// Primitive operations are functions that are actually not functions but somehow instruction primites defined directly in the backend
enum BackendPrimitiveOperation {
	boolCtor, /// Implicit constructor for the Bool (initalizes to false)
}