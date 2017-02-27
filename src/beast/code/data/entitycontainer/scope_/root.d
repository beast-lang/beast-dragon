module beast.code.data.entitycontainer.scope_.root;

import beast.code.data.toolkit;

/// Root scope = there is no parent scope (there is however parent_ dataEntity)
class RootDataScope : DataScope {

public:
	this( Namespace parentNamespace, DataEntity parentInstance ) {
		parentNamespace_ = parentNamespace;
		parentInstance_ = parentInstance;
		identificationString_ = parentNamespace.identificationString;
	}

public:
	final string identificationString( ) {
		return identificationString_;
	}

public:
	final override Overloadset resolveIdentifierRecursively( Identifier id ) {
		if ( auto result = super.resolveIdentifierRecursively( id ) )
			return result;

		if ( auto result = parentNamespace_.resolveIdentifierRecursively( id, parentInstance_ ) )
			return result;

		return Overloadset( );
	}

private:
	Namespace parentNamespace_;
	DataEntity parentInstance_;
	string identificationString_;

}
