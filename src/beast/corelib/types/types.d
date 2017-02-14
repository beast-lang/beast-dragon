module beast.corelib.types.types;

import beast.corelib.toolkit;
import beast.corelib.types.type;

struct CoreLibrary_Types {

public:
	@initialize {
		BeastType_Type Type;
		BeastType_Bool Bool;
	}

public:
	void initialize( void delegate( Symbol ) sink ) {
		// Auto generated initialization function
		foreach( memName; __traits( derivedMembers, typeof( this ) ) ) {
			alias mem = Alias!( __traits( getMember, this, memName ) );
			static if( hasUda!( mem, initialize ) ) {
				mem = new typeof( mem );
				sink( mem.symbol );
			}
		}
	}

private:
	alias initialize = Decorator!"CoreLibrary_Types.initialize";

}
