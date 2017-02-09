module beast.core.project.codesource;

import std.path;
import std.file;
import beast.toolkit;
import beast.util.identifiable;

/// Abstraction of any code source (for matching line numbers, lexing, etc.)
class CodeSource {

public:
	struct CTOR_FromFile {
	}

public:
	this( CTOR_FromFile _, string filename ) {
		absoluteFilePath = filename.absolutePath( project.basePath );

		try {
			// TODO: better line endings conversion
			content = absoluteFilePath.readText.splitLines.joiner( "\n" ).to!string;
		}
		catch ( FileException exc ) {
			berror( E.fileError, "File error: " ~ exc.msg, ( ErrorMessage err ) { err.codeLocation = CodeLocation( this ); } );
		}

		// Calculate newlines
		{
			size_t[ ] newlinePositions = [ 0 ];
			foreach ( int i, char ch; content ) {
				if ( ch == '\n' )
					newlinePositions ~= i;
			}
			newlinePositions ~= content.length;
			newlinePositions_ = newlinePositions;
		}
	}

public:
	const string absoluteFilePath;

	/// File contents
	const string content;

public:
	/// Returns line number (counting from 1) of nth char of the content (counting from 0)
	final size_t lineNumberAt( size_t offset ) const
	out ( result ) {
		assert( offset >= content.length || ( offset >= newlinePositions_[ result - 1 ] && offset < newlinePositions_[ result ] ) );
	}
	body {
		if ( offset >= content.length )
			return newlinePositions_.length;

		// Binary search
		size_t low = 0, high = newlinePositions_.length - 1;

		while ( true ) {
			const size_t mid = ( high + low ) / 2;

			if ( offset < newlinePositions_[ mid ] )
				high = mid - 1;

			else if ( offset >= newlinePositions_[ mid + 1 ] )
				low = mid + 1;

			else if ( offset >= newlinePositions_[ mid ] && offset < newlinePositions_[ mid + 1 ] )
				return mid + 1;

			else
				assert( 0 );
		}

		assert( 0 );
	}

	/// Returns position of the '\n' of the specified line (counting from 1)
	final size_t lineNumberStart( size_t lineNumber ) const {
		assert( lineNumber > 0 && lineNumber <= newlinePositions_.length );
		return newlinePositions_[ lineNumber - 1 ];
	}

public:
	/// Index = line number (counting from 0), value = position of the '\n' in the file
	const size_t[ ] newlinePositions_;

}
