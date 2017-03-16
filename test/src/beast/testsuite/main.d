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

	auto getoptResult = getopt( args, //
			std.getopt.config.bundling, //
			"show-logs", "Show logs of failed tests in the stdout", &showLogs //
			 );

	if ( getoptResult.helpWanted ) {
		defaultGetoptPrinter( "Beast testsuite.", getoptResult.options );
		return 0;
	}

	testsMutex = new Mutex;
	testsDir = "../test/tests".absolutePath;
	"../test/log/".mkdirRecurse( );
	"../test/output/".mkdirRecurse( );

	Test[ ] tests, activeTests, failedTests;

	foreach ( location; testsDir.dirEntries( "t_*", SpanMode.depth ) ) {
		const string loc = location.asNormalizedPath.to!string;
		const string id = location.asRelativePath( testsDir ).to!string.pathSplitter.map!( x => x.chompPrefix( "t_" ).stripExtension ).joiner( "." ).to!string;
		tests ~= new Test( loc, id ~ "_singleThread", true );
		tests ~= new Test( loc, id, false );
	}

	activeTests = tests;

	// Parallel version bugs a lot on Windows
	version( Windows )
		auto it = tests;
	else
		auto it = tests.parallel;

	foreach ( test; it ) {
		const bool result = test.run( );

		synchronized ( testsMutex ) {
			if ( result ) {
				writeln( "[   ] ", test.identifier, ": PASSED" );
			}
			else {
				writeln( "[ # ] ", test.identifier, ": FAILED" );
				failedTests ~= test;

				if ( showLogs )
					test.logFilename.readText.writeln;
			}
		}
	}

	writeln;
	writeln( "[   ] PASSED: ", activeTests.length - failedTests.length );
	writeln( "[ ", failedTests.length ? "#" : " ", " ] FAILED: ", failedTests.length );

	thread_joinAll();

	return failedTests.length ? 1 : 0;
}
