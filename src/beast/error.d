module beast.error;

import std.exception;
import std.format;

ErrorContext*[] errorContextStack;

/// This struct
struct ErrorContext {

public:
	string key;
	string delegate() value;

public:
	@disable this();
	this( string key, lazy string value ) {
		this.key = key;
		this.value = { return value; };

		errorContextStack ~= &this;
	}
	~this() {
		errorContextStack.length --;
	}

}

/// Base error class for all compiler generated exceptions (that are expected)
final class BeastError : Exception {

public:
	this( string message, string file = __FILE__, size_t line = __LINE__ ) {
		foreach( ctx; errorContextStack )
			message ~= "\n  " ~ ctx.key ~ ": " ~ ctx.value();

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
