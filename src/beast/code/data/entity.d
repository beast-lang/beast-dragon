module beast.code.data.entity;

import beast.code.data.toolkit;
import beast.util.identifiable;

/// DataEntity stores information about a value: what is its type and how to obtain it (how to build code that obtains it)
abstract class DataEntity : Identifiable {

public:
	this( DataScope scope_ ) {
		scope__ = scope_;
	}

public:
	/// Type of the data
	abstract @property Symbol_Type dataType( );

	/// Scope of the data (the data is valid only during existence of the scope) - may be null => global scope
	final @property DataScope scope_( ) {
		return scope__;
	}

	/// If the data is known at compiletime
	abstract @property bool isCtime( );

	/// Data value (if isCtime, otherwise throws an exception)
	@property MemoryPtr value( ) {
		berror( E.valueNotCtime, "Value of '%s' is not known at compile time".format( identificationString ) );
		assert( 0 );
	}

public:
	/// Identifier of the data that vaguely corresponds with the symbol table (can be null)
	@property Identifier identifier( ) {
		return null;
	}

	/// Identification of the entity for error printing purposes
	@property string identification( ) {
		if ( auto id = identifier )
			return id.str;

		return "(expression)";
	}

	@property string identificationString( ) {
		return ( scope__ ? scope__.identificationString ~ "." : "" ) ~ identification;
	}

public:
	Overloadset resolveIdentifier( Identifier id ) {
		if ( auto result = dataType.resolveIdentifier( id, this ) )
			return result;

		return Overloadset( );
	}

	Overloadset resolveIdentifierRecursively( Identifier id ) {
		if ( auto result = resolveIdentifier( id ) )
			return result;

		return Overloadset( );
	}

private:
	DataScope scope__;

}
