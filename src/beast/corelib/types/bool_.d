module beast.corelib.types.bool_;

import beast.code.sym.toolkit;
import beast.code.sym.type.staticclass;

final class Symbol_Type_Bool : Symbol_StaticClassType {

public:
	override @property Identifier identifier( ) {
		return Identifier.preobtained!"Bool";
	}

	override @property size_t instanceSize( ) {
		return 1;
	}

public:
	// TODO: more stuff

}
