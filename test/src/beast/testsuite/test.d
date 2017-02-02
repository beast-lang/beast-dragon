module beast.testsuite.test;

import beast.testsuite.directive.directive;
import std.exception;
import std.stdio;
import std.path;
import std.file;
import std.regex;
import std.process;
import std.json;

final class TestFailException : Exception {

public:
	this( ) {
		super( "Test failed" );
	}

}

final class Test {

public:
	this( string location, string identifier ) {
		this.location = location;
		this.identifier = identifier;
	}

public:
	bool run( ) {
		try {
			_run( );
			return true;
		}
		catch ( TestFailException exc ) {
			return false;
		}
	}

public:
	void _run( ) {
		string[ ] sourceFiles;
		/// List of files the test suite will be scanning for directives
		string[ ] scanFiles;
		string projectFile;
		string projectRoot;

		// If the test is just one file, add it to the file list
		if ( location.isFile ) {
			enforce( location.extension == ".be", "Test file '" ~ location ~ "' does not have extension .be" );
			sourceFiles = [ location ];
			scanFiles = sourceFiles;
			projectRoot = location.dirName;

		}
		// Otherwise the test must be a directory; test if it has custom project configuration
		else if ( "beast.json".absolutePath( location ).exists ) {
			// Source files should be configured in the beast.json file
			projectFile = "beast.json".absolutePath( location );
			projectRoot = location;
			// However we need to scan for them for test directives
			scanFiles = location.dirEntries( ".be", SpanMode.depth ).map!( x => x.name.asNormalizedPath.to!string ).array;
		}
		// If there is not project configuration, just add all the .be files from the directory
		else {
			projectRoot = location;
			sourceFiles = location.dirEntries( ".be", SpanMode.depth ).map!( x => x.name.asNormalizedPath.to!string ).array;
			scanFiles = sourceFiles;
		}

		TestDirective[ ] directives;
		// Scan files and get directives from them
		foreach ( fileName; scanFiles ) {
			// Scan the file by lines
			size_t line = 1;
			foreach ( lineStr; fileName.File( "r" ).byLine ) {
				// Find "//! xxxx \n" on each line
				foreach ( comment; lineStr.matchAll( ctRegex!"//!(.*?)$" ) ) {
					directives ~= TestDirectiveArguments.parseAndCreateDirectives( fileName, line, this, comment[ 1 ].idup );
				}

				line++;
			}
		}

		string[ ] args;

		// Prepare arguments
		{
			args = [ "beast", // Compiler name
				"--json-messages", // Compiler messages in JSON format
				"--root", projectRoot, //
				 ];

			// Add explicit source files
			foreach ( file; sourceFiles )
				args ~= [ "--source", file ];

			if ( projectFile )
				args ~= [ "--project", projectFile ];
		}

		// Run process
		ProcessPipes process = pipeProcess( args, Redirect.stdout | Redirect.stderr );
		const int exitCode = process.pid.wait( );

		import std.stdio;

		writeln( "args: ", args.joiner( " " ).array );
		writeln( "exit code: ", exitCode );

		// Process results
		enforce( process.stdout.byLine.empty, "Stdout not empty (stdout directives not yet implemented)" );

		// Test if errors were expected
		foreach ( errorStr; process.stderr.byLine ) {
			import std.stdio;

			writeln( "stderr: ", errorStr );
			try {
				JSONValue[ string ] val = errorStr.parseJSON.object;

				bool errorIsHandled = false;
				foreach ( d; directives ) {
					if ( d.onCompilationError( val ) )
						errorIsHandled = true;
				}

				enforce( errorIsHandled, "Unexpected compiler error: " ~ val[ "gnuFormat" ].str );
			}
			catch ( JSONException exc ) {
				fail( "Stderr JSON parsing error: " ~ exc.msg );
			}
		}

		foreach ( d; directives )
			d.onBeforeTestEnd( );
	}

public:
	/// Location the test is related to
	const string location;
	/// Identifier of the test
	const string identifier;

private:
	void enforce( bool condition, lazy string message ) {
		if ( !condition )
			fail( message );
	}

	void fail( string message ) {
		stderr.writefln( "%s: %s", identifier, message );
		throw new TestFailException;
	}

}
