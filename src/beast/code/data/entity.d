module beast.code.data.entity;

alias DynamicDataEntity = DataEntity delegate( DataEntity instance );

abstract class DataEntity : Identifiable {

public:
	this( DataScope scope_ ) {
		scope__ = scope_;
	}

public:
	/// Type of the data
	abstract @property BeastType type( );

	/// Scope of the data (the data is valid only during existence of the scope) - may be null => global scope
	final @property DataScope scope_( ) {
		return scope__;
	}

	/// If the data is known at compiletime
	abstract @property bool isCtime( );

	/// Data value (if isCtime, otherwise throws an exception)
	@property MemoryPtr value( ) {
		berror( E.valueNotCtime, "Value of '%s' is not known at compile time".format( identificationString ) );
	}

public:
	/// Identifier of the data that vaguely corresponds with the symbol table (can be null)
	@property Identifier identifier( ) {
		return null;
	}

	final @property string identificationString( ) {
		string result;

		if ( scope__ )
			result = scope__.identificationString;

		if ( result )
			result ~= ".";

		if ( auto id = identifier )
			result ~= id.str;
		else
			result ~= "(expression)";

		return result;
	}

public:
	Overloadset resolveIdentifier( Identifier id ) {
		return Overloadset( );
	}

	Overloadset resolveIdentifierRecursively( Identifier id ) {
		if ( auto result = resolveIdentifier( id ) )
			return result;

		return scope__ ? scope__.resolveIdentifierRecursively( id ) : Overloadset( );
	}

private:
	DataScope scope__;

}
