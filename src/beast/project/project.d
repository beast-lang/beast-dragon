module beast.project.project;

import beast.project.configuration;
import beast.toolkit;
import beast.project.sourcefile;
import beast.utility.identifiable;

/// Project wrapping class
final class Project : Identifiable {

public:
	ProjectConfiguration configuration;

public:
	override @property string identificationString( ) {
		return "<project>";
	}

public:
	mixin TaskGuard!( "sourceFileList", SourceFile[ ] );
	mixin TaskGuard!( "text", string );

private:
	SourceFile[ ] obtain_sourceFileList( ) {
		SourceFile[] x = sourceFileList;
		return null;
	}
	string obtain_text() {
		return "asd";
	}

}
