module beast.code.data.entitycontainer.container;

import beast.code.data.toolkit;

/// Parent class of scopes and namespaces
abstract class EntityContainer : Identifiable {

public:
	abstract bool isScope( );
	final bool isNamespace( ) {
		return !isScope;
	}

	abstract Namespace asNamespace( );
	abstract DataScope asScope( );

}
