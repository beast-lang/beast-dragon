module beast.corelib.types.type;

import beast.code.sym.toolkit;
import beast.code.sym.type.staticclass;
import beast.code.namespace.bootstrap;

/// Type 'Type' -- typeof all classes etc.
/// The root of all good and evil in Beast.
/// Here be dragons
final class Symbol_Type_Type : Symbol_StaticClassType {

public:
	this( Namespace parentNamespace ) {
		super( parentNamespace );

		namespace_ = new BootstrapNamespace( this );
		namespace_.initialize( null );
	}

public:
	override Identifier identifier( ) {
		return Identifier.preobtained!"Type";
	}

	override size_t instanceSize( ) {
		return size_t.sizeof;
	}

	override Namespace namespace( ) {
		return namespace_;
	}

public:
	override Overloadset resolveIdentifier( Identifier id, DataEntity instance ) {
		// Tweak so that Type T = C; T.cc evaluates to C.cc
		if ( instance )
			return instance.ctValue_Type.resolveIdentifier( id );

		if ( auto result = super.resolveIdentifier( id, instance ) )
			return result;

		return Overloadset( );
	}

private:
	BootstrapNamespace namespace_;

}
