module beast.main;

import std.stdio;
import std.getopt;
import std.concurrency;

import beast.toolkit;

void mainImpl( string[ ] args ) {
	HookAppInit.call( );
	HookAppStart.call( );

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

	context.project.configuration.loadFromFile( projectFile );

	context.taskManager.waitForEverythingDone( );
	HookAppUninit.call( );
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
