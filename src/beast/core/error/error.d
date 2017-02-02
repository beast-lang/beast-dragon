module beast.core.error.error;

public import std.format : format;

import beast.toolkit;
import beast.core.project.codelocation;
import beast.core.project.configuration;
import beast.utility.enumassoc;
import beast.core.error;
import core.sync.mutex;
import std.algorithm;
import std.exception;
import std.stdio;
import std.json;
import std.traits;
import std.meta;
import beast.utility.decorator;

static __gshared Mutex stderrMutex;
private alias warning = Decorator!( "error.warning" );
private alias hint = Decorator!( "error.hint" );

/// Beast error
enum E {
	// GENERAL: 
	invalidOpts, /// Invalid options passed to the application
	fileError, /// File opening/reading error
	invalidProjectConfiguration, /// Error when parsing project file or invalid configuration combination
	unimplemented, /// Feature not yet implemented
	dependencyLoop, /// Task guard circular dependency

	// LEXER:
	unexpectedCharacter, /// Unexpected character when lexing
	unclosedComment, /// Found EOF when scanning for end of comment block

	// PARSER:
	unexpectedToken, /// Unexpected token

	// MODULES:
	moduleImportFail, /// Module import failed
	invalidModuleIdentifier, /// Invalid module identifier - contains unsupported characters
	moduleNameConflict, /// Two modules with same name
	moduleNameMismatch, /// Expected module name does not match with the actual one (in module statement in the beginning of the file)
}

enum ErrorSeverity {
	error,
	error_nothrow,
	warning,
	hint
}

enum ErrorSeverity[ E ] ErrorSeverityAssoc = { //
	ErrorSeverity[ E ] result;

	foreach ( memberName; __traits( derivedMembers, E ) ) {
		alias member = Alias!( __traits( getMember, E, memberName ) );

		ErrorSeverity severity = ErrorSeverity.error;

		static if ( hasUDA!( member, warning ) )
			severity = ErrorSeverity.warning;
		else static if ( hasUDA!( member, hint ) )
			severity = ErrorSeverity.hint;

		result[ member ] = severity;
	}

	return result;
}( );

enum string[ ErrorSeverity ] ErrorSeverityStrings = [ ErrorSeverity.error : "error", ErrorSeverity.error_nothrow : "error", ErrorSeverity.warning : "warning", ErrorSeverity.hint : "hint" ];

/// If the condition is not true, calls berror
pragma( inline ) void benforce( bool throwIfError = true, string file = __FILE__, size_t line = __LINE__ )( bool condition, E error, lazy string message, lazy ErrorGuardFunction errGdFunc = null ) {
	if ( !condition )
		breport!( throwIfError, file, line )( error, message, errGdFunc );
}

/// Generates error/warning/hint, eventually throwing an exception
pragma( inline ) void breport( bool throwIfError = true, string file = __FILE__, size_t line = __LINE__ )( E error, string message, ErrorGuardFunction errGdFunc = null ) {
	ErrorMessage msg = new ErrorMessage;
	msg.message = message;
	msg.error = error;
	msg.severity = ErrorSeverityAssoc[ error ];

	foreach ( func; context.errorGuardData.stack )
		func( msg );

	if ( errGdFunc )
		errGdFunc( msg );

	const string formattedMessage = context.project.messageFormatter.formatErrorMessage( msg );

	synchronized ( stderrMutex )
		stderr.writeln( formattedMessage );

	if ( msg.severity == ErrorSeverity.error && throwIfError )
		throw new BeastErrorException( message, file, line );
}

/// Generates error/warning/hint, eventually throwing an exception
pragma( inline ) void berror( string file = __FILE__, size_t line = __LINE__ )( E error, string message, ErrorGuardFunction errGdFunc = null ) {
	breport!( ErrorSeverity.error, file, line )( error, message, errGdFunc );
}

/// Base error class for all compiler generated exceptions (that are expected)
final class BeastErrorException : Exception {

public:
	this( string message, string file = __FILE__, size_t line = __LINE__ ) {
		super( message, file, line );
	}

}

private enum _init = HookAppInit.hook!(  {
	stderrMutex = new Mutex; //
} );
