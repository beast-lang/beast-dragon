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

		with ( memoryManager.session )
			ctimeValue_ = memoryManager.alloc( size_t.sizeof, MemoryBlock.Flags.doNotGCAtSessionEnd ).writePrimitive( typeUID_ );
	}

	/// Each type has uniquie UID in the project (differs each compiler run)
	final size_t typeUID( ) {
		return typeUID_;
	}

	/// Size of instance in bytes
	abstract size_t instanceSize( );

public:
	final Overloadset resolveIdentifier( Identifier id, DataScope scope_, DataEntity instance ) {
		{
			auto result = appender!( DataEntity[ ] );

			// Add direct members to the overloadset
			result ~= namespace.resolveIdentifier( id, instance );

			if ( result.data )
				return Overloadset( result.data );
		}

		// Look in the core.Type
		if ( this !is coreLibrary.types.Type ) {
			if ( auto result = coreLibrary.types.Type.resolveIdentifier( id, scope_, this.dataEntity ) )
				return result;
		}

		return Overloadset( );
	}

protected:
	/// Namespace with members of this type (static and dynamic)
	abstract Namespace namespace( );

private:
	MemoryPtr ctimeValue_;
	size_t typeUID_;

protected:
	abstract class Data : SymbolRelatedDataEntity {

	public:
		this( ) {
			super( this.outer );
		}

	public:
		override Symbol_Type dataType( ) {
			return coreLibrary.types.Type;
		}

		override bool isCtime() {
			return true;
		}

	public:
		final override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			cb.build_staticMemoryAccess( this.outer.ctimeValue_ );
		}

	}

}
