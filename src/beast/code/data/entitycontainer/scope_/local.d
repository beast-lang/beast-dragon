module beast.code.data.entitycontainer.scope_.local;

import beast.code.data.toolkit;

final class LocalDataScope : DataScope {

public:
	this( DataScope parent ) {
		assert( parent );

		parent_ = parent;
		identificationString_ = parent_.identificationString;

		debug {
			assert( parent_.openSubscope_ is null );
			parent_.openSubscope_ = this;
		}
	}

public:
	final string identificationString( ) {
		return identificationString_;
	}

public:
	override void finish( ) {
		super.finish( );

		debug {
			assert( parent_.openSubscope_ is this );
			parent_.openSubscope_ = null;
		}
	}

public:
	final override Overloadset resolveIdentifierRecursively( Identifier id ) {
		if ( auto result = super.resolveIdentifierRecursively( id ) )
			return result;

		if ( auto result = parent_.resolveIdentifierRecursively( id ) )
			return result;

		return Overloadset( );
	}

private:
	DataScope parent_;
	string identificationString_;

}
