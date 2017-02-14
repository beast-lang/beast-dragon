module beast.corelib.types.bool_;

import beast.code.sym.toolkit;

final class BeastType_Bool : BeastType {

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
