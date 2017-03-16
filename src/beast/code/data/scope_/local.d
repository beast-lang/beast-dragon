module beast.code.data.scope_.local;

import beast.code.data.toolkit;

final class LocalDataScope : DataScope {

	public:
		this( ) {
			assert( currentScope );
			super( currentScope.parentEntity );

			parentScope_ = currentScope;

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
		final override Overloadset recursivelyResolveIdentifier( Identifier id ) {
			if ( auto result = resolveIdentifier( id ) )
				return result;

			if ( auto result = parentScope_.recursivelyResolveIdentifier( id ) )
				return result;

			return Overloadset( );
		}

	private:
		DataScope parentScope_;

}
