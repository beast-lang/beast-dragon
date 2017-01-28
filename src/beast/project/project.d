module beast.project.project;

import beast.project.configuration;
import beast.toolkit;
import beast.utility.identifiable;
import beast.project.modulemgr.modulemgr;
import beast.project.modulemgr.standard;
import std.file;

/// Project wrapping class
final class Project : Identifiable {

public:
	this( ) {
		basePath = getcwd( );
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

public:
	/// Finishes the configuration, initializing the project with it. After calling this function, the configuration MUST NOT BE CHANGED
	void finishConfiguration( ) {
		// Deduce project mode if not done yet
		if ( configuration.projectMode == ProjectConfiguration.ProjectMode.implicit ) {
			const bool hasSourceDirectories = configuration.sourceDirectories.length > 0;
			const bool hasOriginSourceFile = configuration.originSourceFile !is null;

			if ( hasSourceDirectories && !hasOriginSourceFile )
				configuration.projectMode = ProjectConfiguration.ProjectMode.standard;

			else if ( hasOriginSourceFile && !hasSourceDirectories )
				configuration.projectMode = ProjectConfiguration.ProjectMode.fast;

			else
				berror( CodeLocation.none, BError.invalidProjectConfiguration, "Error deducing project mode: either sourceDirectories and originSourceFile are both set or neither of them" );
		}

		// Construct module manager
		switch ( configuration.projectMode ) {

		case ProjectConfiguration.ProjectMode.standard:
			moduleManager = new StandardModuleManager;
			break;

		case ProjectConfiguration.ProjectMode.fast:
			berror( CodeLocation.none, BError.unimplemented, "Fast project mode not yet implemented" );
			break;

		default:
			assert( 0 );

		}
	}

}
