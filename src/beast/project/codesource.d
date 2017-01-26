module beast.project.codesource;

import std.path;
import std.file;
import beast.toolkit;
import beast.utility.identifiable;

final class CodeSource {

public:
	this( string fileName ) {
		absoluteFilePath = fileName.absolutePath( context.project.basePath );

		try {
			content = readText( absoluteFilePath );
		}
		catch ( FileException exc ) {
			berror( CodeLocation( this ), BError.fileError, "File error: " ~ exc.msg );
		}
	}

public:
	const string absoluteFilePath;
	const string content;

}
