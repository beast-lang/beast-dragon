module beast.project.project;

import beast.project.configuration;
import beast.toolkit;
import beast.project.sourcefile;
import beast.utility.identifiable;

/// Project wrapping class
final class Project : Identifiable {

public:
	this( ) {
		sourceFileListGuard_ = TaskGuard( "sourceFileList", this );
	}

public:
	ProjectConfiguration configuration;

public:
	@property SourceFile[ ] sourceFileList( ) {
		if ( sourceFileListGuard_.startWorkingOrReturnTrue( ) )
			return sourceFileList_;

		sourceFileListGuard_.finish( );
		return sourceFileList_;
	}

	override @property string identificationString() {
		return "<project>";
	}

private:
	SourceFile[ ] sourceFileList_;
	TaskGuard sourceFileListGuard_;

}
