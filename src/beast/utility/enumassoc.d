module beast.utility.enumassoc;

import std.traits;

/// Returns associative array identifier => enum
template enumAssoc( Enum ) if ( is( Enum == enum ) ) {
	enum Enum[ string ] R = {
		Enum[ string ] result;

		foreach ( key; __traits( derivedMembers, Enum ) )
			result[ key ] = __traits( getMember, Enum, key );

		return result;
	}( );

	alias enumAssoc = R;
}

/// Returns associative array enum => identifier
template enumAssocInvert( Enum ) if ( is( Enum == enum ) ) {
	enum string[ Enum ] R = {
		string[ Enum ] result;

		foreach ( key; __traits( derivedMembers, Enum ) )
			result[ __traits( getMember, Enum, key ) ] = key;

		return result;
	}( );

	alias enumAssocInvert = R;
}
