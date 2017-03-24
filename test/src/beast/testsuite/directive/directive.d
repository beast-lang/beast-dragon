module beast.testsuite.directive.directive;

public import beast.testsuite.test;
import beast.testsuite.main;
import std.algorithm;
import std.string;
import std.array;
import std.stdio;
import std.exception;
import std.typecons;

public {
	import std.conv;
	import std.json;
	import std.array;
	import std.algorithm;
	import std.format;
}

abstract class TestDirective {

	public:
		/// Source file the directive was declared
		string declSourceFile;
		/// Line number of the source file the directive was declared
		size_t declLine;
		/// Test this directive is created for
		Test test;

	public:
		/// This is called on compilation error. Returns if this directive covers the error (if the error was expected) -- if no directive covers an error, the test fails
		bool onCompilationError( JSONValue[ string ] errorData ) {
			return false;
		}

		/// This is called right before the test starts, useful for adding args
		void onBeforeTestStart( ) {

		}

		/// This is called right before test end, so the directive can do more checks
		bool onBeforeTestEnd( int exitCode ) {
			return false;
		}

	protected:
		void enforce( bool condition, lazy string message ) {
			if ( !condition )
				fail( message );
		}

		void fail( string message ) {
			synchronized ( testsMutex )
				stderr.writefln( "\n      %s:%s:%s: %s\n", test.identifier, declSourceFile, declLine, message.replace( "\n", "\n        " ) );

			throw new TestFailException( message );
		}

}

class TestDirectiveArguments {

	public:
		string name;
		string mainValue;
		string[ string ] opts;
		alias opts this;

	public:
		TestDirective createDirective( string file, size_t line, Test test ) {
			TestDirective result;

			try {
				result = _createDirective( file, line, test );
			}
			catch ( ConvException exc ) {
				throw new Exception( "%s:%s:%s: Invalid directive data: ".format( test.identifier, file, line, exc.msg ) );
			}

			result.declSourceFile = file;
			result.declLine = line;
			result.test = test;
			return result;
		}

		private TestDirective _createDirective( string file, size_t line, Test test ) {
			import beast.testsuite.directive.error : TestDirective_Error;
			import beast.testsuite.directive.onlylexing : TestDirective_OnlyLexing;
			import beast.testsuite.directive.onlyparsing : TestDirective_OnlyParsing;
			import beast.testsuite.directive.stdout : TestDirective_Stdout;

			switch ( name ) {

			case "error", "warning", "hint":
				return new TestDirective_Error( this );

			case "onlyLexing":
				return new TestDirective_OnlyLexing( this );

			case "onlyParsing":
				return new TestDirective_OnlyParsing( this );

			case "stdout":
				return new TestDirective_Stdout( this );

			default:
				assert( 0, "%s:%s:%s: Unknown directive '%s'".format( test.identifier, file, line, name ) );

			}
		}

	public:
		/// Parses a directive comment into an argument list
		static TestDirectiveArguments[ ] parse( string file, size_t line, Test test, string data ) {
			TestDirectiveArguments[ ] result;

			foreach ( directiveStr; data.splitter( ";" ) ) {
				auto optsStr = directiveStr.splitter( "," ).map!( ( x ) { auto y = x.findSplit( ":" ); return tuple( y[ 0 ].strip, y[ 1 ], y[ 2 ].strip ); } );
				enforce( !optsStr.empty, "%s:%s:%s: No directive data".format( test.identifier, file, line ) );

				auto mainVal = optsStr.front;
				optsStr.popFront;

				TestDirectiveArguments arg = new TestDirectiveArguments;
				arg.name = mainVal[ 0 ];
				arg.mainValue = mainVal[ 2 ];

				// optData is result of findSplit :, so "name : value" results to [ name, ":", value ] and "name" to [ name, null, null ]
				foreach ( optData; optsStr )
					arg.opts[ optData[ 0 ] ] = optData[ 2 ];

				result ~= arg;
			}

			return result;
		}

		static TestDirective[ ] parseAndCreateDirectives( string file, size_t line, Test test, string data ) {
			return parse( file, line, test, data ).map!( x => x.createDirective( file, line, test ) ).array;
		}

}
