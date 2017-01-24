module beast.project.project;

import beast.project.configuration;
import beast.toolkit;
import beast.project.sourcefile;
import beast.utility.identifiable;
import beast.project.modulemgr.modulemgr;

/// Project wrapping class
final class Project : Identifiable {

public:
	ProjectConfiguration configuration;
	ModuleManager moduleManager;

public:
	override final @property string identificationString( ) {
		return "<project>";
	}

}
