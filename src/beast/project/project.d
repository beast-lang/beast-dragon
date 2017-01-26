module beast.project.project;

import beast.project.configuration;
import beast.toolkit;
import beast.utility.identifiable;
import beast.project.modulemgr.modulemgr;
import std.file;

/// Project wrapping class
final class Project : Identifiable {

public:
this() {
	basePath = getcwd();
}

public:
	ProjectConfiguration configuration;
	ModuleManager moduleManager; 

public:
	/// Path to project root directory
	string basePath;

public:
	override final @property string identificationString( ) const {
		return "<project>";
	}

}
