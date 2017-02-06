module beast.main;

import beast.core.project.configuration;
import beast.core.project;
import beast.core.task.manager;
import beast.toolkit;
import std.concurrency;
import std.getopt;
import std.json;
import std.path;
import std.stdio;
import std.file;

void mainImpl( string[ ] args ) {
	HookAppInit.call( );

	taskManager = new TaskManager;
	scope ( exit ) {
		taskManager.waitForEverythingDone( );
		taskManager.quitWorkers( );
	}
	project = new Project;

	/// Absolute file path of project file
	string projectFile;
	/// Root directory of the project as set by --root
	string root;
	/// Number of source files added to the project using --source
	size_t sourceFileCount;
	/// Project configuration options set by arguments
	JSONValue[ string ] optConfigs;
	/// Project file content, if set by stdin
	string stdinProjectData;
	bool doProject = true;

	GetoptResult getoptResult;
	try {
		getoptResult = getopt( args, //
				std.getopt.config.bundling, //
				"project|p", "Location of project configuration file.", ( string opt, string val ) { //
					benforce( !projectFile, E.invalidOpts, "Cannot set multiple project files" );
					projectFile = val.absolutePath;
				}, //
				"project-stdin", "Loads the project configuration from stdin (until EOF).", ( ) { //
					stdinProjectData = stdin.byLine.joiner( "\n" ).to!string;
				}, //
				"source|s", "Adds specified source file to the project.", ( string opt, string val ) { //
					sourceFileCount++;
					optConfigs[ "sourceFiles@opt-origin" ~ sourceFileCount.to!string ] = [ val.absolutePath.to!string ];
				}, //
				"root", "Root directory of the project.", &root, //
				"run|r", "Run the target application after a successfull build.", { //
					optConfigs[ "runAfterBuild" ] = true;
				}, //

				"config", "Override project configuration option. See --help-config for possible options. \nUsage: --config <optName>=<value>, for example --config messageFormat=json (arrays are separated with comma)", ( string opt, string val ) { //
					// TODO: Smart config vals
					const auto data = val.findSplit( "=" );
					const string key = data[ 0 ].strip;
					const string value = data[ 2 ].strip;

					optConfigs[ key ] = ProjectConfiguration.processSmartOpt( key, value );
				}, //

				"json-messages", "Print messages in JSON format.", { //
					optConfigs[ "messageFormat" ] = "json";
				}, //

				"help-config", "Shows documentation of project configuration.", { //
					project.configuration.printHelp( );
					doProject = false;
				} //
				 );
	}
	catch ( GetOptException exc ) {
		berror( E.invalidOpts, exc.msg );
	}

	if ( getoptResult.helpWanted ) {
		writeln( "Dragon - Beast language compiler" );
		writeln;
		writeln( "Authors: " );
		writeln( "  Daniel 'Danol' Cejchan | czdanol@gmail.com" );
		writeln;
		writeln( "Options:" );
		foreach ( opt; getoptResult.options )
			writef( "  %s\n    %s\n\n", opt.optShort ~ ( opt.optShort && opt.optLong ? " | " : "" ) ~ opt.optLong, opt.help.replace( "\n", "\n    " ) );

		doProject = false;
	}

	if ( !doProject )
		return;

	// Find out project root
	if ( root )
		project.basePath = root;
	else if ( projectFile )
		project.basePath = projectFile.dirName;

	// If no project is set (and the mode is not fast), load implicit configuration file (if it exists)
	if ( "originSourceFile" !in optConfigs && !projectFile && absolutePath( "beast.json", project.basePath ).exists )
		projectFile = "beast.json";

	// Build project configuration
	{
		ProjectConfigurationBuilder configBuilder = new ProjectConfigurationBuilder;

		if ( projectFile )
			configBuilder.applyFile( projectFile );

		if ( stdinProjectData ) {
			try {
				configBuilder.applyJSON( stdinProjectData.parseJSON );
			}
			catch ( JSONException exc ) {
				berror( E.invalidProjectConfiguration, "Stdin project configuration parsing failed: " ~ exc.msg );
			}
		}

		configBuilder.applyJSON( JSONValue( optConfigs ) );
		project.configuration.load( configBuilder.build( ) );
	}

	project.finishConfiguration( );
	taskManager.spawnWorkers( );
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
