module beast.main;

import beast.code.hwenv.hwenv;
import beast.code.hwenv.native;
import beast.code.memory.memorymgr;
import beast.core.error.error;
import beast.core.project.configuration;
import beast.core.project.project;
import beast.core.task.taskmgr;
import beast.corelib.corelib;
import beast.toolkit;
import core.stdc.stdlib : exit, EXIT_SUCCESS, EXIT_FAILURE;
import std.algorithm.searching : findSplit;
import std.array : replace;
import std.file : exists;
import std.getopt : getopt, GetoptResult, GetOptException;
import std.json;
import std.path : absolutePath, dirName, pathSplitter;
import std.stdio : stdin, writeln, writef, stderr, write;
import std.string : strip;
import std.process : execute;

static import std.getopt;

void mainImpl( string[ ] args ) {
	HookAppInit.call( );

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
				"project|p", "Location of project configuration file", ( string opt, string val ) { //
					benforce( !projectFile, E.invalidOpts, "Cannot set multiple project files" );
					projectFile = val.absolutePath;
				}, //
				"project-stdin", "Loads the project configuration from stdin (until EOF)", ( ) { //
					stdinProjectData = stdin.byLine.joiner( "\n" ).to!string;
				}, //
				"source|s", "Adds specified source file to the project", ( string opt, string val ) { //
					sourceFileCount++;
					optConfigs[ "sourceFiles@opt-origin" ~ sourceFileCount.to!string ] = [ val.absolutePath.to!string ];
				}, //
				"output-directory", "Location where the output files are generated to", ( string opt, string val ) { //
					optConfigs[ "outputDirectory" ] = val.absolutePath;
				}, //
				"target-filename", "Filename of the output file", ( string opt, string val ) { //
					optConfigs[ "targetFilename" ] = val;
				}, //
				"root", "Root directory of the project", &root, //
				"run|r", "Run the target application after a successfull build", { //
					optConfigs[ "runAfterBuild" ] = true;
				}, //

				"config", "Override project configuration option; See --help-config for possible options. \nUsage: --config <optName>=<value>, for example --config messageFormat=json (arrays are separated with comma)", ( string opt, string val ) { //
					// TODO: Smart config vals
					const auto data = val.findSplit( "=" );
					const string key = data[ 0 ].strip;
					const string value = data[ 2 ].strip;

					optConfigs[ key ] = ProjectConfiguration.processSmartOpt( key, value );
				}, //

				"json-messages", "Print messages in JSON format", { //
					optConfigs[ "messageFormat" ] = "json";
				}, //

				"help-config", "Shows documentation of project configuration", { //
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

	benforce( args.length == 1, E.invalidArgs, "Invalid arguments provided. Type 'beast --help' for help." );

	if ( !doProject )
		return;

	// Find out project root
	if ( root )
		project.basePath = root;
	else if ( projectFile )
		project.basePath = projectFile.dirName;

	project.configuration.targetFilename = project.basePath.pathSplitter.back;

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

	// Construct base classes
	taskManager = new TaskManager;
	scope ( exit ) {
		taskManager.waitForEverythingDone( );
		taskManager.quitWorkers( );
	}

	hardwareEnvironment = new HardwareEnvironment_Native;
	memoryManager = new MemoryManager;

	/*
		Core library must be constructed before finishing configuration of the project,
		because finishConfiguration initializes module list
		*/
	constructCoreLibrary( );
	project.finishConfiguration( );

	// Give the compiler a job
	foreach ( m; project.moduleManager.initialModuleList )
		taskManager.imminentIssueJob( { m.enforceDone_parsing( ); } );

	taskManager.spawnWorkers( );

	{
		// There will be some delayedIssuedJobs in the main thread (minimally because core library is created in the main thread)
		foreach ( job; context.delayedIssuedJobs )
			taskManager.imminentIssueJob( job );

		context.delayedIssuedJobs = null;
	}

	if (  /*!wereErrors &&*/ project.configuration.stopOnPhase >= ProjectConfiguration.StopOnPhase.codegen ) {
		// Start building code using backend
		project.backend.build( );
	}

	if ( !wereErrors && project.configuration.stopOnPhase >= ProjectConfiguration.StopOnPhase.outputgen && project.configuration.runAfterBuild ) {
		auto executeResult = project.configuration.targetFilename.execute( );

		executeResult.output.write( );
		benforce( executeResult.status == 0, E.binaryExecutionFailed, "Built program resuled with exit code %s".format( executeResult.status ) );
	}

	assert( !context.delayedIssuedJobs.length );
}

int main( string[ ] args ) {
	try {
		mainImpl( args );

		debug ( phases )
			writeln( "main ok exit" );

		return wereErrors ? 2 : 0;
	}
	catch ( BeastErrorException err ) {
		debug ( phases )
			writeln( "main err exit" );

		return 3;
	}
	catch ( Throwable t ) {
		stderr.writeln( "UNCAUGHT EXCEPTION: " ~ t.toString );
		// Disgracefully shutdown the application
		exit( 4 );
		assert( 0 );
	}
}
