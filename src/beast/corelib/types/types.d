module beast.corelib.types.types;

import beast.corelib.types.toolkit;
import beast.corelib.types.type;
import beast.corelib.types.bool_;
import beast.corelib.types.void_;

struct CoreLibrary_Types {

	public:
		Symbol_Type_Type Type;
		Symbol_Type_Bool Bool;
		Symbol_Type_Void Void;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			sink( Type = new Symbol_Type_Type( parent ) );
			sink( Bool = new Symbol_Type_Bool( parent ) );
			sink( Void = new Symbol_Type_Void( parent ) );
		}

}
