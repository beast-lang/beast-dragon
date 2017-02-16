module beast.code.data.scope_.root;

import beast.code.data.toolkit;

/// Root scope = there is no parent scope (there is however parent_ dataEntity)
class RootDataScope : DataScope {

public:
	this( DataEntity parent ) {
		assert( parent );
		parent_ = parent;
	}

public:
	final string identificationString( ) {
		return parent_.identificationString;
	}

public:
	override ref size_t currentBasePointerOffset( ) {
		return currentBasePointerOffset_;
	}

public:
	/// Deallocates scope ctime stack
	final void finish( ) {

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
	DataEntity parent_;
	string identification_;
	size_t currentBasePointerOffset_;

}
