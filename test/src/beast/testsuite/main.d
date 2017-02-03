module beast.testsuite.main;

import beast.testsuite.test;
import std.path;
import std.file;
import std.array;
import std.conv;
import std.string;
import std.stdio;
import std.algorithm;

int main( string[ ] args ) {
	immutable string testsDir = "../test/tests".absolutePath;

	Test[ ] tests, activeTests, failedTests;

	foreach ( location; testsDir.dirEntries( "t_*", SpanMode.depth ) )
		tests ~= new Test( location.asNormalizedPath.to!string, location.asRelativePath( testsDir ).to!string.pathSplitter.map!( x => x.chompPrefix( "t_" ).stripExtension ).joiner( "." ).to!string );

	activeTests = tests;

	foreach ( test; tests ) {
		if ( test.run( ) ) {
			writeln( "[   ] ", test.identifier, ": PASSED" );
		}
		else {
			writeln( "[ # ] ", test.identifier, ": FAILED" );
			failedTests ~= test;
		}
	}

	writeln;
	writeln( "[   ] PASSED: ", activeTests.length - failedTests.length );
	writeln( "[ ", failedTests.length ? "#" : " ", " ] FAILED: ", failedTests.length );

	return failedTests.length ? 1 : 0;
}
