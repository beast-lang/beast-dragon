module beast.testsuite.main;

import beast.testsuite.test;
import std.path;
import std.file;
import std.array;
import std.conv;
import std.string;
import std.stdio;
import std.algorithm;
import std.parallelism;
import core.sync.mutex;
import std.getopt;
import core.thread;

__gshared Mutex testsMutex;
__gshared string testsDir, testRootDir;

int main( string[ ] args ) {
	bool showLogs;
	bool onlyFailed;

	auto getoptResult = getopt( args, //
			std.getopt.config.bundling, //
			"showLogs", "Show logs of failed tests in the stdout", &showLogs, //
			"f|onlyFailed", "Only executes previously failed tests", &onlyFailed //
			 );

	if ( getoptResult.helpWanted ) {
		defaultGetoptPrinter( "Beast testsuite.", getoptResult.options );
		return 0;
	}

	testsMutex = new Mutex;
	testsDir = "../test/tests".absolutePath;
	"../test/log/".mkdirRecurse( );
	"../test/output/".mkdirRecurse( );
	"../test/tmp/".mkdirRecurse( );

	bool[ string ] previouslySucceededTests;
	if ( onlyFailed ) {
		foreach ( ln; "../test/log/succeeded.txt".readText.replace( "\r", "" ).splitter( "\n" ) )
			previouslySucceededTests[ ln ] = true;
	}

	File log = File( "../test/log/log.txt", "w" );
	File succeededTestsLog = File( "../test/log/succeeded.txt", onlyFailed ? "a" : "w" );

	Test[ ] tests, activeTests, failedTests;

	foreach ( location; testsDir.dirEntries( "t_*", SpanMode.depth ) ) {
		const string loc = location.asNormalizedPath.to!string;
		const string id = location.asRelativePath( testsDir ).to!string.pathSplitter.map!( x => x.chompPrefix( "t_" ).stripExtension ).joiner( "." ).to!string;

		version ( Windows ) {
		}
		else {
			tests ~= new Test( loc, id ~ "_singleThread", 1 );
			//tests ~= new Test( loc, id ~ "_twoThreads", 2 );
		}
		tests ~= new Test( loc, id, 0 );
	}

	foreach ( test; tests ) {
		if ( onlyFailed && test.identifier in previouslySucceededTests )
			continue;

		activeTests ~= test;
	}

	// Parallel version bugs a lot on Windows
	version ( Windows )
		auto it = activeTests;
	else
		auto it = activeTests.parallel;

	foreach ( test; it ) {
		const bool result = test.run( );

		synchronized ( testsMutex ) {
			string str;
			if ( result ) {
				str = "[   ] %s: PASSED\n".format( test.identifier );
				succeededTestsLog.writeln( test.identifier );
			}

			else {
				str = "[ # ] %s: FAILED\n".format( test.identifier );
				failedTests ~= test;

				if ( showLogs )
					str ~= test.logFilename.readText ~ "\n";
			}

			log.write( str );
			stdout.write( str );
			stdout.flush( );
		}
	}

	string str = "\n[   ] PASSED: %s\n[ %s ] FAILED: %s\n".format( activeTests.length - failedTests.length, failedTests.length ? "#" : " ", failedTests.length );
	stdout.write( str );
	log.write( str );

	thread_joinAll( );

	return failedTests.length ? 1 : 0;
}
