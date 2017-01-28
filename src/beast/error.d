module beast.error;

public import std.format : format;

import beast.toolkit;
import beast.project.codelocation;
import beast.project.configuration;
import beast.utility.enumassoc;
import core.sync.mutex;
import std.algorithm;
import std.exception;
import std.stdio;
import std.json;

static __gshared Mutex stderrMutex;

enum BError {
	/// Invalid options passed to the application
	invalidOpts,

	/// File opening/reading error
	fileError,

	/// Error when parsing project file or invalid configuration combination
	invalidProjectConfiguration,

	/// Lexer error
	unexpectedCharacter,

	/// Feature not yet implemented
	unimplemented,
}

enum BErrorSeverity {
	error,
	error_nothrow,
	warning,
	hint
}

enum string[ BErrorSeverity ] BErrorSeverityStrings = [ BErrorSeverity.error : "error", BErrorSeverity.error_nothrow : "error", BErrorSeverity.warning : "warning", BErrorSeverity.hint : "hint" ];

/// If the condition is not true, calls berror
pragma( inline ) void benforce( BErrorSeverity severity = BErrorSeverity.error, string file = __FILE__, size_t line = __LINE__ )( bool condition, lazy const CodeLocation codeLocation, BError error, lazy string message ) {
	if ( !condition )
		breport!( severity, file, line )( codeLocation, error, message );
}

/// Generates error/warning/hint, eventually throwing an exception
pragma( inline ) void breport( BErrorSeverity severity, string file = __FILE__, size_t line = __LINE__ )( const CodeLocation codeLocation, BError error, string message ) {
	string formattedMessage;

	// Format the message
	final switch ( context.project.configuration.messageFormat ) {

	case ProjectConfiguration.MessageFormat.gnu: {
			if ( codeLocation.source ) {
				formattedMessage ~= codeLocation.file ~ ":";

				if ( codeLocation.startLine ) {
					formattedMessage ~= codeLocation.startLine.to!string ~ "." ~ codeLocation.startColumn.to!string;
					if ( codeLocation.endLine != codeLocation.startLine )
						formattedMessage ~= "-" ~ codeLocation.endLine.to!string ~ "." ~ codeLocation.endColumn.to!string;
					else
						formattedMessage ~= "-" ~ codeLocation.endColumn.to!string;

					formattedMessage ~= ":";
				}

			}
			else
				formattedMessage = "beast:";

			formattedMessage ~= " " ~ BErrorSeverityStrings[ severity ] ~ ": " ~ /* enumAssocInvert!( BError )[ error ] ~ " | " ~ */ message;
		}
		break;

	case ProjectConfiguration.MessageFormat.json: {
			JSONValue[ string ] result;
			result[ "type" ] = BErrorSeverityStrings[ severity ];
			result[ "error" ] = enumAssocInvert!( BError )[ error ];
			result[ "message" ] = message;

			if ( codeLocation.source ) {
				result[ "file" ] = codeLocation.source.absoluteFilePath;
				if ( codeLocation.startPos ) {
					// TODO: Add more data (endLine, ...)
					formattedMessage = "compiler:";
					result[ "startLine" ] = codeLocation.startLine;
				}
			}

			formattedMessage = JSONValue( result ).toString;
		}
		break;

	}

	synchronized ( stderrMutex )
		stderr.writeln( formattedMessage );

	if ( severity == BErrorSeverity.error )
		throw new BeastErrorException( message, file, line );
}

/// Generates error/warning/hint, eventually throwing an exception
pragma( inline ) void berror( string file = __FILE__, size_t line = __LINE__ )( const CodeLocation codeLocation, BError error, string message ) {
	breport!( BErrorSeverity.error, file, line )( codeLocation, error, message );
}

/// Base error class for all compiler generated exceptions (that are expected)
final class BeastErrorException : Exception {

public:
	this( string message, string file = __FILE__, size_t line = __LINE__ ) {
		super( message, file, line );
	}

}

shared static this( ) {
	stderrMutex = new Mutex;
}
