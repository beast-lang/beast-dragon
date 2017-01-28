module beast.main;

import beast.project.configuration;
import beast.project.project;
import beast.task.manager;
import beast.toolkit;
import std.concurrency;
import std.getopt;
import std.json;
import std.path;
import std.stdio;
import std.string;

void mainImpl( string[ ] args ) {
	HookAppInit.call( );

	context.taskManager = new TaskManager;
	scope ( exit ) {
		context.taskManager.waitForEverythingDone( );
		context.taskManager.quitWorkers( );
	}
	context.project = new Project;

	enum ProjectMode {
		implicit,
		projectFile,
		fastBuild
	}

	ProjectMode projectMode;
	string projectFile = "beast.json";

	JSONValue[ string ] optExplicitConfiguration;
	string[ string ] optConfigs;

	GetoptResult getoptResult;

	try {
		getoptResult = getopt( args, //
				std.getopt.config.bundling, //
				"project-file|p", "Location of project configuration file.", ( string opt, string val ) { //
					benforce( projectMode == ProjectMode.implicit, CodeLocation.none, BError.invalidOpts, "Project mode already set" );
					context.project.basePath = opt.dirName.absolutePath;
					projectMode = ProjectMode.projectFile;
					projectFile = opt;
				}, //

				"config", "Override project configuration option. See --help-config for possible options. \nUsage: --config <optName>=<jsonValue>, for example --config messageFormat=\"json\"", &optConfigs, //

				"json-messages", "Print messages in JSON format.", { //
					context.project.configuration.messageFormat = ProjectConfiguration.MessageFormat.json;
					optExplicitConfiguration[ "messageFormat" ] = "json";
				}, //

				"help-config", "Shows documentation of project configuration.", { //
					context.project.configuration.printHelp( );
				} //
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
			writef( "  %s\n    %s\n\n", opt.optShort ~ ( opt.optShort && opt.optLong ? " | " : "" ) ~ opt.optLong, opt.help.replace( "\n", "\n    " ) );
	}

	if ( projectMode == ProjectMode.implicit ) {
		projectMode = projectMode.projectFile;
	}

	// Build project configuration
	{
		ProjectConfigurationBuilder configBuilder = new ProjectConfigurationBuilder;

		if ( projectMode == ProjectMode.projectFile )
			configBuilder.applyFile( projectFile );

		foreach ( key, value; optConfigs ) {
			JSONValue val;
			try {
				val = value.parseJSON;
			}
			catch ( JSONException exc ) {
				berror( CodeLocation.none, BError.invalidOpts, value ~ " Config opt '" ~ key ~ "' value parsing failed: " ~ exc.msg );
			}

			optExplicitConfiguration[ key ] = val;
		}

		configBuilder.applyJSON( JSONValue( optExplicitConfiguration ) );
		context.project.configuration.load( configBuilder.build( ) );
	}
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
