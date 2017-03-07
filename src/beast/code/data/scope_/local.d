module beast.code.data.scope_.local;

import beast.code.data.toolkit;

final class LocalDataScope : DataScope {

	public:
		this( DataScope parentScope ) {
			super( parentScope.parentEntity );

			parentScope_ = parentScope;

			debug {
				assert( parentScope_.openSubscope_ is null );
				parentScope_.openSubscope_ = this;
			}
		}

	public:
		override void finish( ) {
			super.finish( );

			debug {
				assert( parentScope_.openSubscope_ is this );
				parentScope_.openSubscope_ = null;
			}
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
