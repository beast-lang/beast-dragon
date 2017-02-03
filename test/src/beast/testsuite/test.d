module beast.testsuite.test;

import beast.testsuite.directive.directive;
import beast.testsuite.main;
import std.algorithm;
import std.conv;
import std.exception;
import std.file;
import std.json;
import std.path;
import std.process;
import std.regex;
import std.stdio;
import std.string;

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
		log = File( "../test/log/" ~ identifier ~ ".txt", "w" );
		log.writeln( "Test '", identifier, "' log\n" );

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
			scanFiles = location.dirEntries( "*.be", SpanMode.depth ).map!( x => x.name.asNormalizedPath.to!string ).array;
		}
		// If there is not project configuration, just add all the .be files from the directory
		else {
			projectRoot = location;
			sourceFiles = location.dirEntries( "*.be", SpanMode.depth ).map!( x => x.name.asNormalizedPath.to!string ).array;
			scanFiles = sourceFiles;
		}

		TestDirective[ ] directives;
		// Scan files and get directives from them
		foreach ( fileName; scanFiles ) {
			// Scan the file by lines
			size_t line = 1;
			foreach ( lineStr; fileName.readText.splitLines ) {
				// Try finding "//! xxxx \n" on each line
				foreach ( comment; lineStr.matchAll( ctRegex!"//!(.*?)$" ) )
					directives ~= TestDirectiveArguments.parseAndCreateDirectives( fileName, line, this, comment[ 1 ].idup );

				line++;
			}
		}

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

		foreach ( d; directives )
			d.onBeforeTestStart( );

		log.writeln( "Test command: \n", args.joiner( " " ), "\n" );
		log.flush( );

		string[ ] stderrContent;
		string stdoutContent;
		// Run process
		{
			ProcessPipes process = pipeProcess( args, Redirect.stdout | Redirect.stderr );
			const int exitCode = process.pid.wait( );

			stderrContent = process.stderr.byLine.map!( x => x.to!string ).array;
			stdoutContent = process.stdout.byLine.joiner( "\n" ).to!string;
		}
		// Log STDERR
		{
			log.writeln( "-- BEGIN OF STDERR" );

			foreach ( str; stderrContent )
				log.write( str );

			log.writeln( "-- END OF STDERR\n" );
		}

		// Process results
		enforce( !stdoutContent.length, "Stdout not empty (stdout directives not yet implemented): " ~ stdoutContent );

		// Test if errors were expected
		{
			foreach ( errorStr; stderrContent ) {
				try {
					JSONValue[ string ] val = errorStr.parseJSON.object;

					bool errorIsHandled = false;
					foreach ( d; directives )
						errorIsHandled |= d.onCompilationError( val );

					enforce( errorIsHandled, "Unexpected compiler error: \n" ~ val[ "gnuFormat" ].str );
				}
				catch ( JSONException exc ) {
					fail( "Stderr JSON parsing error: " ~ exc.msg );
				}
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
	File log;
	/// Args to run the compiler with
	string[ ] args;

private:
	void enforce( bool condition, lazy string message ) {
		if ( !condition )
			fail( message );
	}

	void fail( string message ) {
		synchronized ( testsMutex )
			stderr.writefln( "\n      %s: %s\n", identifier, message.replace( "\n", "\n        " ) );

		throw new TestFailException;
	}

}
