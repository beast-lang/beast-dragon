module beast.code.sym.type.type;

import beast.code.sym.toolkit;
import beast.util.uidgen;

__gshared UIDKeeper!Symbol_Type typeUIDKeeper;
private enum _init = HookAppInit.hook!( { typeUIDKeeper.initialize( ); } );

/// Type in the Beast language
abstract class Symbol_Type : Symbol {

public:
	this( ) {
		typeUID_ = typeUIDKeeper( this );
	}

	/// Each type has uniquie UID in the project (differs each compiler run)
	final @property size_t typeUID( ) {
		return typeUID_;
	}

	/// Size of instance in bytes
	abstract @property size_t instanceSize( );

	/// Namespace with members of this type (static and dynamic)
	abstract @property Namespace namespace( );

	public:
		/// Resolves identifier 
		Overloadset resolveIdentifier( Identifier id, DataEntity instance ) {
			{
				auto result = appender!( DataEntity[ ] );

				// Add direct members to the overloadset
				result ~= namespace.resolveIdentifier( id ).map!( x => x.data( instance ) );

				if ( result.data )
					return Overloadset( result.data );
			}

			// Look in the core.Type
			if ( auto result = coreLibrary.types.Type.data( null ).resolveIdentifier( id ) )
				return result;

			return Overloadset( );
		}

	private:
		size_t typeUID_;

	}
