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

	string projectFile;

	string[ string ] optConfigs;

	GetoptResult getoptResult;

	try {
		getoptResult = getopt( args, //
				std.getopt.config.bundling, //
				"project-file|p", "Location of project configuration file.", ( string opt, string val ) { //
					benforce( !projectFile, E.invalidOpts, "Cannot set multiple project files" );
					context.project.basePath = opt.dirName.absolutePath;
					projectFile = val;
				}, //
				"origin|o", "Location of the origin source file (sets project mode to fast).", ( string opt, string val ) { //
					optConfigs[ "projectMode" ] = "\"fast\"";
					optConfigs[ "originSourceFile" ] = '"' ~ val ~ '"';
					context.project.basePath = opt.dirName.absolutePath;
				}, //
				"run|r", "Run the target application after a successfull build.", { //
					optConfigs[ "runAfterBuild" ] = "true";
				}, //

				"config", "Override project configuration option. See --help-config for possible options. \nUsage: --config <optName>=<jsonValue>, for example --config messageFormat=\"json\"", &optConfigs, //

				"json-messages", "Print messages in JSON format.", { //
					context.project.configuration.messageFormat = ProjectConfiguration.MessageFormat.json;
					optConfigs[ "messageFormat" ] = "\"json\"";
				}, //

				"help-config", "Shows documentation of project configuration.", { //
					context.project.configuration.printHelp( );
				} //
				 );
	}
	catch ( GetOptException exc ) {
		berror( E.invalidOpts, exc.msg );
	}

	if ( getoptResult.helpWanted ) {
		writeln( "Beast language compiler" );

		writeln;
		writeln( "Options:" );
		foreach ( opt; getoptResult.options )
			writef( "  %s\n    %s\n\n", opt.optShort ~ ( opt.optShort && opt.optLong ? " | " : "" ) ~ opt.optLong, opt.help.replace( "\n", "\n    " ) );
	}

	// If no project is set (and the mode is not fast), load implicit configuration file
	if ( "originSourceFile" !in optConfigs && !projectFile )
		projectFile = "beast.json";

	// Build project configuration
	{
		ProjectConfigurationBuilder configBuilder = new ProjectConfigurationBuilder;

		if ( projectFile )
			configBuilder.applyFile( projectFile );

		JSONValue[ string ] userConfig;

		foreach ( key, value; optConfigs ) {
			JSONValue val;
			try {
				val = value.parseJSON;
			}
			catch ( JSONException exc ) {
				berror( E.invalidOpts, value ~ " Config opt '" ~ key ~ "' value parsing failed: " ~ exc.msg );
			}

			userConfig[ key ] = val;
		}

		configBuilder.applyJSON( JSONValue( userConfig ) );
		context.project.configuration.load( configBuilder.build( ) );
	}

	context.project.finishConfiguration( );
	context.taskManager.spawnWorkers( );
}

int main( string[ ] args ) {
	try {
		mainImpl( args );
		return 0;
	}
	catch ( BeastErrorException err ) {
		return -1;
	}
}
