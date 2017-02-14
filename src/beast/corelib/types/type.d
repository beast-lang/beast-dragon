module beast.corelib.types.type;

import beast.code.sym.toolkit;

/// Type 'Type' -- typeof all classes etc.
/// The root of all good and evil in Beast.
/// Here be dragons
final class BeastType_Type : BeastType {

public:
	override @property Identifier identifier( ) {
		return Identifier.preobtained!"Type";
	}

	override @property size_t instanceSize( ) {
		return size_t.sizeof;
	}

public:
	override Overloadset resolveIdentifier( Identifier id, MemoryPtr variableValue ) {
		// We're using resolveIdentifier_noCoreType to prevent recursion (as type of Type is Type again)
		if ( auto result = super.resolveIdentifier_noCoreType( id, variableValue ) )
			return result;

		/*
			This is to make stuff like this work
			@ctime Type T = C;
			T.somethingThatIs C's member
		*/
		BeastType type = typeUIDKeeper[ variableValue.readPrimitive!size_t ];
		benforce( type !is null, E.invalidData, "Invalid Type variable value" );
		if ( type !is this ) { // Prevent "@ctime Type type = Type" recursion
			if ( auto result = type.resolveIdentifier( id, nullMemoryPtr ) )
				return result;
		}

		return Overloadset( );
	}

}
