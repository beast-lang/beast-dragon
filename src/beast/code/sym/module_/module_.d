module beast.code.sym.module_.module_;

import beast.code.sym.toolkit;
import beast.corelib.corelib;

/// Module as a symbol
/// See also Module from beast.core.project.module_ with module as project file
abstract class Symbol_Module : Symbol {

public:
	final override @property BaseType baseType( ) {
		return BaseType.module_;
	}

public:
	override Overloadset recursivelyResolveIdentifier( Identifier id ) {
		// We do not call super.recursivelyResolveIdentifier here - there should be no parent

		if ( Overloadset result = resolveIdentifier( id ) )
			return result;

		// Hardwired core library 'import'
		if ( Overloadset result = coreLibrary.module_.resolveIdentifier( id ) )
			return result;

		return Overloadset( );
	}

}
