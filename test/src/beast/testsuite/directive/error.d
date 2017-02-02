module beast.testsuite.directive.error;

import beast.testsuite.directive.directive;

final class TestDirective_Error : TestDirective {

public:
	this( TestDirectiveArguments args ) {
		errorType = args.mainValue;

		if ( "line" in args )
			line = args.opts[ "line" ].to!size_t;

		watchFile = "nofile" !in args;
		watchLine = watchFile && "noline" !in args;
	}

public:
	override bool onCompilationError( JSONValue[ string ] errorData ) {
		if ( watchFile && errorData[ "file" ].str != file )
			return false;

		if ( watchLine && errorData[ "line" ].integer != line )
			return false;

		if ( errorType && errorData[ "type" ].str != errorType )
			return false;

		satisfied = true;
		return true;
	}

	override void onBeforeTestEnd( ) {
		enforce( satisfied, errorMsg );
	}

public:
	string file;
	size_t line;
	string errorType;
	bool watchLine;
	bool watchFile;
	bool satisfied;

protected:
	string errorMsg( ) {
		string result = "Expected error";

		if ( errorType )
			result ~= " '%s'".format( errorType );

		return result;
	}

}
