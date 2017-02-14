module beast.code.data.scope_;

import beast.code.data.toolkit;

abstract class DataScope : Identifiable {

public:
	Overloadset resolveIdentifier( Identifier id ) {
		return Overloadset( );
	}

	Overloadset resolveIdentifierRecursively( Identifier id ) {
		if ( auto result = resolveIdentifier( id ) )
			return result;

		return Overloadset( );
	}

}
