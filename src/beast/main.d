module beast.main;

import std.stdio;
import std.getopt;
import std.concurrency;

import beast.toolkit;
import beast.task.manager;
import beast.project.project;

void mainImpl( string[ ] args ) {
	HookAppInit.call( );

	string projectFile = "beast.json";
	GetoptResult getoptResult;

	try {
		getoptResult = getopt( args, //
				std.getopt.config.bundling, //
				"project-file|p", "Location of project configuration file.", &projectFile //
				 );
	}
	catch ( GetOptException exc ) {
		berror( CodeLocation.none, BError.invalidOpts, exc.msg );
	}

	if ( getoptResult.helpWanted ) {
		writeln( "Beast language compiler" );

		writeln;
		writeln( "Options:" );
		foreach ( opt; getoptResult.options )
			writef( "  %s\n    %s\n\n", opt.optShort ~ ( opt.optShort && opt.optLong ? " | " : "" ) ~ opt.optLong, opt.help );
	}

	context.taskManager = new TaskManager;
	scope ( exit ) {
		context.taskManager.waitForEverythingDone( );
		context.taskManager.quitWorkers( );
	}
	context.project = new Project;

	context.project.configuration.loadFromFile( projectFile );
}

int main( string[ ] args ) {
	try {
		mainImpl( args );
		return 0;
	}
	catch ( BeastErrorException err ) {
		// TODO: Format errors
		return -1;
	}
}
