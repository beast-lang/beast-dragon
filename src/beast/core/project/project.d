module beast.core.project.project;

import beast.code.toolkit;
import beast.util.identifiable;
import beast.core.project.configuration;
import beast.core.error.msgfmtr.msgfmtr;
import beast.core.project.modulemgr;
import beast.core.error.msgfmtr.gnu;
import beast.backend.common.backend;
import beast.code.data.function_.rt;
import beast.core.project.module_;
import beast.code.lex.identifier;
import beast.code.data.symbol;

/// Project wrapping class
final class Project : Identifiable {

	public:
		this( ) {
			import std.file : getcwd;

			basePath = getcwd( );
			messageFormatter = new MessageFormatter_GNU( );
			moduleManager = new ModuleManager;

			import beast.backend.cpp.backend : Backend_Cpp;

			version ( cppBackend )
				backend = new Backend_Cpp;

			configuration.initialize( );
		}

	public:
		ProjectConfiguration configuration;
		ModuleManager moduleManager;
		MessageFormatter messageFormatter;
		Backend backend;

	public:
		/// Path to project root directory
		string basePath;

	public:
		Module entryModule( ) {
			if ( project.configuration.entryModule )
				return moduleManager.getModule( project.configuration.entryModule.ExtendedIdentifier );
			else if ( moduleManager.initialModuleList.length == 1 )
				return moduleManager.initialModuleList[ 0 ];
			else
				return moduleManager.getModule( "main".ExtendedIdentifier );
		}

	public:
		override string identificationString( ) const {
			return "<project>";
		}

	public:
		/// Finishes the configuration, initializing the project with it. After calling this function, the configuration MUST NOT BE CHANGED
		void finishConfiguration( ) {
			import std.file : exists, isDir, isFile;
			import std.path : absolutePath;

			messageFormatter = messageFormatterFactory[ configuration.messageFormat ]( );

			// Translate paths
			{
				foreach ( ref string path; configuration.sourceDirectories ) {
					path = path.absolutePath( basePath );
					benforce( path.exists && path.isDir, E.fileError, "Source directory '" ~ path ~ "' does not exist" );
				}

				foreach ( ref string path; configuration.includeDirectories ) {
					path = path.absolutePath( basePath );
					benforce( path.exists && path.isDir, E.fileError, "Include directory '" ~ path ~ "' does not exist" );
				}

				foreach ( ref string file; configuration.sourceFiles ) {
					file = file.absolutePath( basePath );
					benforce( file.exists && file.isFile, E.fileError, "Source file '" ~ file ~ "' does not exist" );
				}

				configuration.outputDirectory = configuration.outputDirectory.absolutePath( basePath );
				configuration.targetFilename = configuration.targetFilename.absolutePath( configuration.outputDirectory );
			}

			moduleManager.initialize( );
		}

}
