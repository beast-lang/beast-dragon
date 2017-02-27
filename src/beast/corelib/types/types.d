module beast.corelib.types.types;

import beast.corelib.toolkit;
import beast.corelib.types.type;
import beast.corelib.types.bool_;
import beast.corelib.types.void_;
import beast.util.decorator;
import std.meta;
import std.traits;

struct CoreLibrary_Types {

public:
	@autoinit {
		Symbol_Type_Type Type;
		Symbol_Type_Bool Bool;
		Symbol_Type_Void Void;
	}

public:
	void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
		// Auto generated initialization function
		foreach ( memName; __traits( derivedMembers, typeof( this ) ) ) {
			alias mem = Alias!( __traits( getMember, this, memName ) );
			static if ( hasUDA!( mem, autoinit ) ) {
				mem = new typeof( mem )( parent );
				sink( mem );
			}
		}
	}

private:
	alias autoinit = Decorator!"CoreLibrary_Types.initialize";

}
