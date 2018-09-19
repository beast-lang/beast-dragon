module beast.testsuite.test;

import beast.testsuite.directive.directive;
import beast.testsuite.main;
import core.thread;
import std.algorithm;
import std.conv;
import std.datetime.stopwatch;
import std.exception;
import std.file;
import std.json;
import std.path;
import std.process;
import std.regex;
import std.stdio;
import std.string;
import std.range;

enum StopOnPhase {
	lexing, /// Do only lexical analysis
	parsing, /// Do lexical and syntax analysis
	codegen,
	outputgen,
	doEverything,
}

immutable StopOnPhaseStr = [ "lexing", "parsing", "codegen", "outputgen" ];

final class Test {

	public:
		this( string location, string identifier, int maxThreads ) {
			this.location = location;
			this.identifier = identifier;
			this.maxThreads = maxThreads;
		}

	public:
		bool run( ) {
			logFilename = "../test/log/%s.txt".format( identifier ).absolutePath;

			File log = File( logFilename, "w" );
			log.writeln( "Test '", identifier, "' log\n" );

			try {
				_run( log );
				return true;
			}
			catch ( TestFailException exc ) {
				log.writefln( "-- FAILED: %s", exc.message );
				return false;
			}

		}

	public:
		void _run( ref File log ) {
			string[ ] sourceFiles;
			/// List of files the test suite will be scanning for directives
			string[ ] scanFiles;
			string projectFile;
			string projectRoot;

			const string outputDirectory = "../test/output".absolutePath;

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
				string beastApp = "beast".absolutePath( getcwd );
				version ( Windows )
					beastApp ~= ".exe";

				args = [ beastApp, // Compiler name
					"--json-messages", // Compiler messages in JSON format
					"--root", projectRoot, //
					"--output-directory", outputDirectory, //
					"--target-filename", identifier, //
					 ];

				if ( maxThreads )
					args ~= [ "--config", "workerCount=%s".format( maxThreads ) ];

				// Add explicit source files
				foreach ( file; sourceFiles )
					args ~= [ "--source", file ];

				if ( projectFile )
					args ~= [ "--project", projectFile ];
			}

			foreach ( d; directives )
				d.onBeforeTestStart( );

			{
				if ( !needsCompilation && stopOnPhase == StopOnPhase.doEverything )
					stopOnPhase = StopOnPhase.codegen;

				if ( stopOnPhase != StopOnPhase.doEverything )
					args ~= [ "--config", "stopOnPhase=%s".format( StopOnPhaseStr[ stopOnPhase ] ) ];

				if ( runAfterBuild )
					args ~= "-r";
			}

			log.writeln( "Test command: \n", args.joiner( " " ), "\n" );
			log.flush( );

			string[ ] stderrContent;
			string stdoutContent;
			int exitCode;

			// Run process
			{
				File fout = File( "../test/tmp/%s.stdout.txt".format( identifier ).absolutePath, "w" );
				File ferr = File( "../test/tmp/%s.stderr.txt".format( identifier ).absolutePath, "w" );

				//ProcessPipes process = pipeProcess( args/*, Redirect.stdout | Redirect.stderr*/ );
				auto pid = spawnProcess( args, stdin, fout, ferr );

				scope ( exit ) {
					stderrContent = ferr.name.readText.replace( "\r", "" ).splitter( "\n" ).filter!( x => !x.empty ).array;
					stdoutContent = fout.name.readText.replace( "\r", "" );

					{
						log.writeln( "-- BEGIN OF STDOUT" );
						log.writeln( stdoutContent );
						log.writeln( "-- END OF STDOUT\n" );
					}
					{
						log.writeln( "-- BEGIN OF STDERR" );
						foreach ( str; stderrContent )
							log.writeln( str );
						log.writeln( "-- END OF STDERR\n" );
					}
				}

				StopWatch sw;
				sw.start( );

				while ( true ) {
					const auto result = pid.tryWait( );

					if ( result.terminated ) {
						exitCode = result.status;
						break;
					}

					if ( sw.peek > timeout.seconds ) {
						pid.kill( );
						fail( "Process timeout" );
					}
					Thread.sleep( sw.peek / 4 );
				}

				log.writefln( "Execution took: %s ms", sw.peek.total!"msecs" );
				log.writefln( "Exit code: %s\n", exitCode );
			}

			// Process results

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
						fail( "Stderr JSON parsing error: " ~ exc.msg ~ "\nLine content: " ~ errorStr ~ "\nEntire stderr:\n" ~ stderrContent.map!( x => "  " ~ x ).joiner( "\n" ).to!string );
					}
				}

			}

			// Check stdout
			{
				log.writeln( "-- begin of expected stdout" );
				log.writeln( expectedStdout );
				log.writeln( "-- end of expected stdout\n" );

				enforce( stdoutContent == expectedStdout, "Stdout does not match expected stdout" );
			}

			bool exitCodeHandled = exitCode == 0;
			foreach ( d; directives )
				exitCodeHandled |= d.onBeforeTestEnd( exitCode );

			enforce( exitCodeHandled, "Unexpected exit code: %s".format( exitCode ) );
		}

	public:
		/// Location the test is related to
		const string location;
		/// Identifier of the test
		const string identifier;
		/// Args to run the compiler with
		string[ ] args;
		string logFilename;
		StopOnPhase stopOnPhase = StopOnPhase.doEverything;
		/// If false, outputgen and run is not executed
		bool needsCompilation;
		bool runAfterBuild;
		/// Timeout in seconds
		int timeout = 3;
		int maxThreads = 0;
		string expectedStdout;

	private:
		void enforce( bool condition, lazy string message ) {
			if ( !condition )
				fail( message );
		}

		void fail( string message ) {
			synchronized ( testsMutex )
				stderr.writefln( "\n ###  %s: %s\n", identifier, message.replace( "\n", "\n        " ) );

			throw new TestFailException( message );
		}

}

final class TestFailException : Exception {

	public:
		this( string msg ) {
			super( msg );

			message = msg;
		}

	public:
		string message;

}
