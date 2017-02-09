module beast.corelib.type;

import beast.code.sym.toolkit;

/// Type 'Type' -- typeof all classes etc.
/// The root of all good and evil in Beast.
/// Here be dragons
final class Symbol_Type_Type : Symbol_Type {

public:
	override @property Identifier identifier( ) {
		return Identifier.preobtained!"Type";
	}

	override @property Symbol_Type type( ) {
		// Yeah baby, Type.#typeof is Type
		return this;
	}

	override @property bool isStatic( ) {
		return true;
	}

}
