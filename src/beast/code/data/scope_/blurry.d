module beast.code.data.scope_.blurry;

import beast.code.data.toolkit;

/// Blurry data scope is same as LocalDataScope, except it allows more blurry scopes to be open at the same time for a parent scope.
/// This is used in overload resolution, where multiple overloads have open scopes at the same time
final class BlurryDataScope : DataScope {

	public:
		this( DataScope parentScope ) {
			super( parentScope.parentEntity );
			assert( parentScope );
			parentScope_ = parentScope;
		}

	public:
		final Overloadset tryRecursivelyResolveIdentifier( Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			if ( auto result = tryResolveIdentifier( id, matchLevel ) )
				return result;

			if ( auto result = parentScope_.tryRecursivelyResolveIdentifier( id, matchLevel ) )
				return result;

			return Overloadset( );
		}

	private:
		DataScope parentScope_;

}
