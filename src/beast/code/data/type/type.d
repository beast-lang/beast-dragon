module beast.code.data.type.type;

import beast.code.data.toolkit;
import beast.util.uidgen;

__gshared UIDKeeper!Symbol_Type typeUIDKeeper;
private enum _init = HookAppInit.hook!( { typeUIDKeeper.initialize( ); } );

/// Type in the Beast language
abstract class Symbol_Type : Symbol {

public:
	this( ) {
		typeUID_ = typeUIDKeeper( this );

		with ( memoryManager.session ) {
			ctimeValue_ = memoryManager.alloc( size_t.sizeof, MemoryBlock.Flags.doNotGCAtSessionEnd );
			ctimeValue_.writePrimitive( typeUID_ );
		}
	}

	/// Each type has uniquie UID in the project (differs each compiler run)
	final size_t typeUID( ) {
		return typeUID_;
	}

	/// Size of instance in bytes
	abstract size_t instanceSize( );

	/// Namespace with members of this type (static and dynamic)
	abstract Namespace namespace( );

	override void parent( EntityContainer set ) {
		super.parent( set );
		namespace.parent = set.asNamespace;
	}

public:
	/// Resolves identifier
	/// Resolving an identifier might result in executing a code in compile time, hence the scope
	Overloadset resolveIdentifier( Identifier id, DataEntity instance = null, DataScope scope_ = null ) {
		{
			auto result = appender!( DataEntity[ ] );

			// Add direct members to the overloadset
			result ~= namespace.resolveIdentifier( id, instance ).data;

			if ( result.data )
				return Overloadset( result.data );
		}

		// Look in the core.Type
		if ( this !is coreLibrary.types.Type ) {
			if ( auto result = coreLibrary.types.Type.data.resolveIdentifier( id ) )
				return result;
		}

		return Overloadset( );
	}

protected:
	MemoryPtr ctimeValue_;

private:
	size_t typeUID_;

}
