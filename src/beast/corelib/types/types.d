module beast.corelib.types.types;

import beast.corelib.toolkit;
import beast.corelib.types.type;
import beast.corelib.types.bool_;
import beast.util.decorator;
import std.meta;
import std.traits;

struct CoreLibrary_Types {

public:
	@initialize {
		Symbol_Type_Type Type;
		Symbol_Type_Bool Bool;
	}

public:
	void initialize( Namespace nmspc, void delegate( Symbol ) sink ) {
		// Auto generated initialization function
		foreach( memName; __traits( derivedMembers, typeof( this ) ) ) {
			alias mem = Alias!( __traits( getMember, this, memName ) );
			static if( hasUDA!( mem, initialize ) ) {
				mem = new typeof( mem ) ( nmspc );
				sink( mem );
			}
		}
	}

private:
	alias initialize = Decorator!"CoreLibrary_Types.initialize";

}
