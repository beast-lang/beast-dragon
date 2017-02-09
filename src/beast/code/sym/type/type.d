module beast.code.sym.type.type;

import beast.code.sym.toolkit;
import beast.util.uidgen;

abstract class Symbol_Type : Symbol_Variable {

public:
	this( ) {
		typeUID_ = typeUIDGenerator( );
	}

public:
	/// Each type has uniquie UID in the project (differs each compiler run)
	final @property size_t typeUID( ) {
		return typeUID_;
	}

	override @property Symbol_Type type( ) {
		return coreLibrary.Type;
	}

private:
	size_t typeUID_;

private:
	static __gshared UIDGenerator typeUIDGenerator;

}
