module beast.testsuite.main;

import beast.testsuite.test;
import std.path;
import std.file;
import std.array;
import std.conv;
import std.string;
import std.stdio;

void main( string[ ] args ) {
	Test[ ] tests, failedTests;

	immutable string testsDir = "../test/tests".absolutePath;
	foreach ( location; testsDir.dirEntries( "test_?*", SpanMode.depth ) )
		tests ~= new Test( location.asNormalizedPath.to!string, location.asRelativePath( testsDir ).to!string.stripExtension.replace( "/", "." ).replace( "\\", "." ).chomp( "." ) );

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
	writeln( "[   ] PASSED: ", tests.length - failedTests.length );
	writeln( "[ ", failedTests.length ? "#" : "", "  ] FAILED: ", failedTests.length );
}
