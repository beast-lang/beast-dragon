module beast.core.project.project;

import beast.code.toolkit;
import beast.util.identifiable;
import beast.core.project.configuration;
import beast.core.error.msgfmtr.msgfmtr;
import beast.core.project.modulemgr;
import beast.core.error.msgfmtr.gnu;

/// Project wrapping class
final class Project : Identifiable {

	public:
		this( ) {
			import std.file : getcwd;
			
			basePath = getcwd( );
			messageFormatter = new MessageFormatter_GNU( );
			moduleManager = new ModuleManager;
		}

	public:
		ProjectConfiguration configuration;
		ModuleManager moduleManager;
		MessageFormatter messageFormatter;

	public:
		/// Path to project root directory
		string basePath;

	public:
		override final string identificationString( ) const {
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

				configuration.targetFilename = configuration.targetFilename.absolutePath( basePath );
			}

			moduleManager.initialize( );
		}

}
