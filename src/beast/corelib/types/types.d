module beast.corelib.types.types;

import beast.corelib.toolkit;
import beast.corelib.types.type;
import beast.corelib.types.bool_;
import beast.corelib.types.void_;
import beast.util.decorator;

struct CoreLibrary_Types {

public:
	Symbol_Type_Type Type;
	Symbol_Type_Bool Bool;
	Symbol_Type_Void Void;

public:
	void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
		Type = new Symbol_Type_Type( parent );
		Bool = new Symbol_Type_Bool( parent );
		Void = new Symbol_Type_Void( parent );
	}

}
