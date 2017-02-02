module beast.testsuite.main;

import beast.testsuite.test;
import std.path;
import std.file;
import std.array;
import std.conv;
import std.string;
import std.stdio;

void main( string[ ] args ) {
	Test[ ] tests;

	immutable string testsDir = "../test/tests".absolutePath;
	foreach ( location; testsDir.dirEntries( "test_?*", SpanMode.depth ) )
		tests ~= new Test( location.asNormalizedPath.to!string, location.asRelativePath( testsDir ).to!string.stripExtension.replace( "/", "." ).replace( "\\", "." ).chomp( "." ) );

	foreach ( test; tests ) {
		writeln( "Running test '" ~ test.identifier ~ "'" );
		const bool result = test.run( );
		writeln( "Test result: " ~ result.to!string );
		writeln;
	}
}
