module beast.code.sym.type.type;

import beast.code.sym.toolkit;
import beast.util.uidgen;

__gshared UIDKeeper!Symbol_Type typeUIDKeeper;
private enum _init = HookAppInit.hook!( { typeUIDKeeper.initialize( ); } );

abstract class Symbol_Type : Symbol_Variable {

public:
	this( ) {
		typeUID_ = typeUIDKeeper( this );
	}

public:
	override @property Symbol_Type type( ) {
		return coreLibrary.Type;
	}

	final override @property bool isCtime( ) {
		return true;
	}

public:
	/// Each type has uniquie UID in the project (differs each compiler run)
	final @property size_t typeUID( ) {
		return typeUID_;
	}

	/// Size of instance in bytes
	abstract @property size_t instanceSize( );

private:
	size_t typeUID_;

}
