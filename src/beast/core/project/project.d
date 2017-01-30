module beast.core.project.project;

import beast.core.project.configuration;
import beast.toolkit;
import beast.utility.identifiable;
import beast.core.project.modulemgr;
import beast.core.error.msgfmtr;
import std.file;
import std.path;

/// Project wrapping class
final class Project : Identifiable {

public:
	this( ) {
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
	override final @property string identificationString( ) const {
		return "<project>";
	}

public:
	/// Finishes the configuration, initializing the project with it. After calling this function, the configuration MUST NOT BE CHANGED
	void finishConfiguration( ) {
		

		// Translate paths
		{
			foreach ( ref string path; configuration.sourceDirectories )
				path = path.absolutePath( basePath );

			foreach ( ref string path; configuration.includeDirectories )
				path = path.absolutePath( basePath );

			foreach ( ref string file; configuration.sourceFiles )
				file = file.absolutePath( basePath );
		}

		moduleManager.initialize( );
	}

}
