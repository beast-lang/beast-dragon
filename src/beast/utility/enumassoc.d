module beast.utility.enumassoc;

import std.traits;

/// Returns associative array identifier => enum
template enumAssoc( Enum ) if ( is( Enum == enum ) ) {
	immutable Enum[ string ] enumAssoc;

	shared static this( ) {
		enumAssoc = {
			Enum[ string ] result;

			foreach ( key; __traits( derivedMembers, Enum ) )
				result[ key ] = __traits( getMember, Enum, key );

			return result;
		}( );
	}
}

/// Returns associative array enum => identifier
template enumAssocInvert( Enum ) if ( is( Enum == enum ) ) {
	immutable string[ Enum ] enumAssocInvert;

	shared static this( ) {
		enumAssocInvert = {
			string[ Enum ] result;

			foreach ( key; __traits( derivedMembers, Enum ) )
				result[ __traits( getMember, Enum, key ) ] = key;

			return result;
		}( );
	}
}
