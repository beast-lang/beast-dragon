module beast.corelib.types.type;

import beast.code.data.toolkit;
import beast.code.data.type.staticclass;
import beast.code.data.entitycontainer.namespace.bootstrap;

/// Type 'Type' -- typeof all classes etc.
/// The root of all good and evil in Beast.
/// Here be dragons
final class Symbol_Type_Type : Symbol_StaticClassType {

public:
	this() {
		namespace_ = new BootstrapNamespace( this, null );
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
	override Overloadset resolveIdentifier( Identifier id, DataEntity instance = null, DataScope scope_ = null ) {
		// Tweak so that Type T = C; T.cc evaluates to C.cc
		// We want to return function now - this resolveIdentifier is called again with null instance from this call
		if ( instance ) {
			assert( instance.dataType is coreLibrary.types.Type );
			return instance.ctExec( scope_ ).readType().resolveIdentifier( id );
		}

		if ( auto result = super.resolveIdentifier( id, instance ) )
			return result;

		return Overloadset( );
	}

private:
	BootstrapNamespace namespace_;

}
