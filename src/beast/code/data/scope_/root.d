module beast.code.data.scope_.root;

import beast.code.data.toolkit;

/// Root scope = there is no parent scope (there is however parent_ dataEntity)
class RootDataScope : DataScope {

	public:
		this( DataEntity parent ) {
			super( parent );
		}

	public:
		final override Overloadset recursivelyResolveIdentifier( Identifier id, DataScope scope_ ) {
			// First look into the scope
			if ( auto result = resolveIdentifier( id, scope_ ) )
				return result;

			// Then look into parent
			if ( auto result = parentEntity.recursivelyResolveIdentifier( id, scope_ ) )
				return result;

			return Overloadset( );
		}

}
