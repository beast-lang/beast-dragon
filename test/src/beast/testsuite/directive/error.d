module beast.testsuite.directive.error;

import beast.testsuite.directive.directive;

/// Expects certain error or warning or somethin
final class TestDirective_Error : TestDirective {

	public:
		this( TestDirectiveArguments args ) {
			severity = args.name;
			errorType = args.mainValue;

			watchFile = "noFile" !in args;
			watchLine = watchFile && ( "noLine" !in args );

			if ( auto val = "lineSpan" in args )
				lineSpan = (*val).to!size_t;
		}

	public:
		override bool onCompilationError( JSONValue[ string ] errorData ) {
			if ( "severity" !in errorData || errorData[ "severity" ].str != severity )
				return false;

			if ( watchFile == ( "file" !in errorData ) || ( watchFile && errorData[ "file" ].str != declSourceFile ) )
				return false;

			if ( watchLine == ( "line" !in errorData ) )
				return false;

			if ( watchLine && ( errorData[ "line" ].integer < declLine || errorData[ "line" ].integer >= declLine + lineSpan ) )
				return false;

			if ( "error" !in errorData || errorData[ "error" ].str != errorType )
				return false;

			satisfied = true;
			return true;
		}

		override bool onBeforeTestEnd( int exitCode ) {
			enforce( satisfied, errorMsg );

			return exitCode != 0 && severity == "error";
		}

	public:
		string errorType, severity;
		size_t lineSpan = 1;
		bool watchLine;
		bool watchFile;
		bool satisfied;

	protected:
		string errorMsg( ) {
			string result = "Expected " ~ severity;

			if ( errorType )
				result ~= " '%s'".format( errorType );

			return result;
		}

}
