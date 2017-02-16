module beast.corelib.types.void_;

import beast.code.sym.toolkit;
import beast.code.sym.type.staticclass;
import beast.code.namespace.bootstrap;

final class Symbol_Type_Void : Symbol_StaticClassType {

public:
	this( Namespace parentNamespace ) {
		super( parentNamespace );

		namespace_ = new BootstrapNamespace( this );
		namespace_.initialize( null );
	}

public:
	override Identifier identifier( ) {
		return Identifier.preobtained!"Void";
	}

	override size_t instanceSize( ) {
		return 0;
	}

	override Namespace namespace( ) {
		return namespace_;
	}

public:
	// TODO: more stuff

private:
	BootstrapNamespace namespace_;

}
