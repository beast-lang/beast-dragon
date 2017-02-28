module beast.core.error.error;

public {
	import beast.core.error.errormsg;
	import beast.core.error.guard;
	import std.format : format;
}

import beast.core.error.error;
import beast.core.project.codelocation;
import beast.core.project.configuration;
import beast.toolkit;
import beast.util.decorator;
import beast.util.enumassoc;
import core.sync.mutex;
import std.exception;
import std.json;
import std.meta;
import std.stdio;
import std.traits;
import core.runtime;

static __gshared Mutex stderrMutex;
private alias warning = Decorator!( "error.warning" );
private alias hint = Decorator!( "error.hint" );

/// Beast error
enum E {
	// GENERAL: 
	invalidOpts, /// Invalid options passed to the application
	fileError, /// File opening/reading error (or directory or smthg)
	invalidProjectConfiguration, /// Error when parsing project file or invalid configuration combination
	notImplemented, /// Feature not yet implemented
	dependencyLoop, /// Task guard circular dependency
	other, /// Other errors

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
	noModulesInSourceDirectory, /// This is a warning, occurs when there's a source directory with no modules in it

	// DECORATORS:
	decoratorConflict, /// Two decorators are incompatible with each other
	duplicitModification, /// For example when using @static twice or when using @static where static is implicit; this is a hint

	// MEMORY (interpreter related, not the compiler memory):
	outOfMemory, /// Interpreter has run out of memory (target machine pointer size can be smaller)
	invalidMemoryOperation, /// Either free, read or write attempt on invalid memory
	protectedMemory, /// Memory block was created in different session and is protected from modifications
	invalidPointer, /// Memory with given address is not allocated
	nullPointer, /// When trying to do something with null pointer
	invalidData, /// Data is somehow invalid (for example invalid Type value)

	// CTIME:
	valueNotCtime, /// Value is not known at compile time

	// OVERLOADSETS:
	noMatchingOverload, /// No overload matches given parameters
	ambiguousResolution, /// Multiple overloads match given parameters
	unknownIdentifier, /// Identifier was not found (either recursively or not)
	cannotInfer, /// No expected type was given where it was needed (mostly inferations)

	// VARIABLES:
	zeroSizeVariable, /// Trying to declare a variable of type void (warning)
}

enum ErrorSeverity {
	error,
	error_nothrow,
	warning,
	hint
}

enum string[ ErrorSeverity ] ErrorSeverityStrings = [ ErrorSeverity.error : "error", ErrorSeverity.error_nothrow : "error", ErrorSeverity.warning : "warning", ErrorSeverity.hint : "hint" ];

/// If the condition is not true, calls berror
pragma( inline ) void benforce( ErrorSeverity severity = ErrorSeverity.error, string file = __FILE__, size_t line = __LINE__ )( bool condition, E error, lazy string message, lazy ErrorGuardFunction errGdFunc = null ) {
	if ( !condition )
		breport!( severity, file, line )( error, message, errGdFunc );
}

/// If the confition is not true, reports a hint
alias benforceHint( string file = __FILE__, size_t line = __LINE__ ) = benforce!( ErrorSeverity.hint, file, line );

/// Generates error/warning/hint, eventually throwing an exception
pragma( inline ) void breport( ErrorSeverity severity = ErrorSeverity.error, string file = __FILE__, size_t line = __LINE__ )( E error, string message, ErrorGuardFunction errGdFunc = null ) {
	ErrorMessage msg = new ErrorMessage;
	msg.message = message;
	msg.error = error;
	msg.severity = severity;

	foreach ( func; context.errorGuardData.stack )
		func( msg );

	if ( errGdFunc )
		errGdFunc( msg );

	const string formattedMessage = project.messageFormatter.formatErrorMessage( msg );

	synchronized ( stderrMutex ) {
		stderr.writeln( formattedMessage );
		if( project.configuration.showStackTrace )
		stderr.writeln( defaultTraceHandler.toString );
	}

	if ( msg.severity == ErrorSeverity.error )
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

private enum _init = HookAppInit.hook!( {
		stderrMutex = new Mutex; //
	} );
