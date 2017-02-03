module beast.testsuite.directive.error;

import beast.testsuite.directive.directive;

final class TestDirective_Error : TestDirective {

public:
	this( TestDirectiveArguments args ) {
		errorType = args.mainValue;

		watchFile = "noFile" !in args;
		watchLine = watchFile && "noLine" !in args;
	}

public:
	override bool onCompilationError( JSONValue[ string ] errorData ) {
		if ( "severity" !in errorData || errorData[ "severity" ].str != "error" )
			return false;

		if ( watchFile == ( "file" !in errorData ) || ( watchFile && errorData[ "file" ].str != declSourceFile ) )
			return false;

		if ( watchLine == ( "line" !in errorData ) || ( watchLine && errorData[ "line" ].integer != declLine ) )
			return false;

		if ( "error" !in errorData || errorData[ "error" ].str != errorType )
			return false;

		satisfied = true;
		return true;
	}

	override void onBeforeTestEnd( ) {
		enforce( satisfied, errorMsg );
	}

public:
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
