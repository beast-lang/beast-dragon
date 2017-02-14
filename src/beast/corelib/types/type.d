module beast.corelib.types.type;

import beast.code.sym.toolkit;
import beast.code.sym.type.staticclass;

/// Type 'Type' -- typeof all classes etc.
/// The root of all good and evil in Beast.
/// Here be dragons
final class Symbol_Type_Type : Symbol_StaticClassType {

public:
	override @property Identifier identifier( ) {
		return Identifier.preobtained!"Type";
	}

	override @property size_t instanceSize( ) {
		return size_t.sizeof;
	}

public:
	override Overloadset resolveIdentifier( Identifier id, DataEntity instance ) {
		// Tweak so that Type T = C; T.cc evaluates to C.cc
		if ( instance ) {
			assert( instance.dataType is this );
			MemoryPtr instVal = instance.value;
			Symbol_Type type = typeUIDKeeper[ instVal.readPrimitive!size_t ];

			benforce( type !is null, E.invalidPointer, "'%s' does not point to a valid type".format( instance.identificationString ) );
			return type.data( null ).resolveIdentifier( id );
		}

		if ( auto result = super.resolveIdentifier( id, instance ) )
			return result;

		return Overloadset( );
	}

}
