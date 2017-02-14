module beast.code.type.type;

import beast.code.sym.toolkit;
import beast.util.uidgen;
import beast.code.sym.var.type;

__gshared UIDKeeper!BeastType typeUIDKeeper;
private enum _init = HookAppInit.hook!( { typeUIDKeeper.initialize( ); } );

/// Type in the Beast language
abstract class BeastType : Identifiable {

public:
	this( ) {
		typeUID_ = typeUIDKeeper( this );
		symbol_ = new Symbol_Variable_Type( this );
	}

public:
	abstract @property Identifier identifier( );

	@property Identifier baseName() {
		return identifier;
	}

	/// Each type has uniquie UID in the project (differs each compiler run)
	final @property size_t typeUID( ) {
		return typeUID_;
	}

	/// Size of instance in bytes
	abstract @property size_t instanceSize( );

public:
	final @property Symbol_Variable_Type symbol( ) {
		return symbol_;
	}

	final @property Symbol parent( ) {
		return symbol_.parent;
	}

	final @property string identificationString() {
		return symbol_.identificationString;
	}

public:
	/// Tries to resolve identifier when eventually knowing variable value at ctime
	/// variableValue is used in the coreLibrary.Type type
	Overloadset resolveIdentifier( Identifier id, MemoryPtr variableValue ) {
		// core.Type might add more info to this
		if ( auto result = coreLibrary.types.Type.resolveIdentifier( id, variableValue ) )
			return result;

		return resolveIdentifier_noCoreType( id, variableValue );
	}

	final Overloadset resolveIdentifier_noCoreType( Identifier id, MemoryPtr variableValue ) {
		return Overloadset( );
	}

private:
	size_t typeUID_;
	Symbol_Variable_Type symbol_;

}
