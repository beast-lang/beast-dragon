module beast.code.data.scope_.blurry;

import beast.code.data.toolkit;

/// Blurry data scope is same as LocalDataScope, except it allows more blurry scopes to be open at the same time for a parent scope.
/// This is used in overload resolution, where multiple overloads have open scopes at the same time
final class BlurryDataScope : DataScope {

	public:
		this( DataScope parentScope ) {
			super( parentScope.parentEntity );
			parentScope_ = parentScope;
		}

	public:
		final override Overloadset recursivelyResolveIdentifier( Identifier id, DataScope scope_ ) {
			if ( auto result = resolveIdentifier( id, scope_ ) )
				return result;

			if ( auto result = parentScope_.recursivelyResolveIdentifier( id, scope_ ) )
				return result;

			return Overloadset( );
		}

	private:
		DataScope parentScope_;

}
