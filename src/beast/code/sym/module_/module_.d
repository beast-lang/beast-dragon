module beast.code.sym.module_.module_;

import beast.code.sym.toolkit;
import beast.corelib.corelib;

/// Module as a symbol
/// See also Module from beast.core.project.module_ with module as project file
abstract class Symbol_Module : Symbol {

public:
	final override @property DeclType declarationType( ) {
		return DeclType.module_;
	}

	abstract @property Namespace namespace();

	final override @property Namespace parentNamespace( ) {
		return null;
	}

public:
	final override DataEntity data( DataEntity instance ) {
		assert( 0 );
		// TODO:
	}

}
