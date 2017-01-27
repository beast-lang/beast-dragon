module beast.main;

import std.stdio;
import std.getopt;
import std.concurrency;
import std.json;

import beast.toolkit;
import beast.project.configuration;
import beast.task.manager;
import beast.project.project;

void mainImpl( string[ ] args ) {
	HookAppInit.call( );

	context.taskManager = new TaskManager;
	scope ( exit ) {
		context.taskManager.waitForEverythingDone( );
		context.taskManager.quitWorkers( );
	}
	context.project = new Project;

	ProjectConfigurationBuilder configBuilder = new ProjectConfigurationBuilder;

	string projectFile = "beast.json";
	JSONValue[ string ] optExplicitConfiguration;

	GetoptResult getoptResult;

	try {
		getoptResult = getopt( args, //
				std.getopt.config.bundling, //
				"project-file|p", "Location of project configuration file.", &projectFile, //
				"json-messages", "Print messages in JSON format", { context.project.configuration.messageFormat = ProjectConfiguration.MessageFormat.json; optExplicitConfiguration[ "messageFormat" ] = "json"; } //
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

	configBuilder.applyFile( projectFile );
	configBuilder.applyJSON( JSONValue( optExplicitConfiguration ) );
	context.project.configuration.load( configBuilder.build( ) );
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
