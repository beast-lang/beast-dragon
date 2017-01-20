module beast.error;

import std.exception;
import std.format;
import std.algorithm;

ErrorContext*[ ] errorContextStack;

/// Exceptions/warnings occured during this struct existence show this struct key-value pair in their error messages
struct ErrorContext {

public:
	string[ string ]delegate( ) data;

public:
	@disable this( );
	this( lazy string[ string ] data ) {
		this.data = { return data; };
		errorContextStack ~= &this;
	}

	~this( ) {
		assert( errorContextStack[ $ - 1 ] is &this );
		errorContextStack.length--;
	}

}

/// Base error class for all compiler generated exceptions (that are expected)
final class BeastError : Exception {

public:
	this( string message, string file = __FILE__, size_t line = __LINE__ ) {
		foreach ( ctx; errorContextStack.map!( x => x.data().byKeyValue ).joiner )
			message ~= "\n  " ~ ctx.key ~ ": " ~ ctx.value;

		super( message, file, line );
	}

}

/// Enforce that generates BeastError exception, allows fancy formatting (using std.format)
pragma( inline ) void benforce( string file = __FILE__, size_t line = __LINE__, Args... )( bool condition, lazy string message, lazy Args args ) {
	if ( !condition )
		berror!( file, line )( message, args );
}

/// Generates BeastError exception, allows fancy formatting (using std.format)
pragma( inline ) void berror( string file = __FILE__, size_t line = __LINE__, Args... )( string message, Args args ) {
	throw new BeastError( message.format( args ), file, line );
}
