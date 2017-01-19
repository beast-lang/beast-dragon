module beast.main;

import std.stdio;
import std.getopt;

import beast.error;
import beast.project.project;

void mainImpl( string[ ] args ) {
	string projectFile = "beast.json";
	GetoptResult getoptResult;

	try {
		getoptResult = getopt( args, //
				std.getopt.config.bundling, //
				"project-file|p", "Location of project configuration file.", &projectFile //
				 );
	}
	catch ( GetOptException exc ) {
		berror( exc.msg );
	}

	if ( getoptResult.helpWanted ) {
		writeln( "Beast language compiler" );

		writeln;
		writeln( "Options:" );
		foreach ( opt; getoptResult.options )
			writef( "  %s\n    %s\n\n", opt.optShort ~ ( opt.optShort && opt.optLong ? " | " : "" ) ~ opt.optLong, opt.help );
	}

	project.configuration.loadFromFile( projectFile );
}

int main( string[ ] args ) {
	try {
		mainImpl( args );
		return 0;
	}
	catch ( BeastError err ) {
		stderr.writeln( "ERROR: " ~ err.msg );
		return -1;
	}
}
