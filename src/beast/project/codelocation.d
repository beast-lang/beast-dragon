module beast.project.codelocation;

import beast.project.codesource;

/// Structure storing information of where a code segment is located in the source code files
struct CodeLocation {

public:
	static immutable CodeLocation none = CodeLocation( null, 0, 0 );

public:
	this( CodeSource source, size_t startPos, size_t length ) {
		this.source = source;
		this.startPos = startPos;
		this.length = length;
	}

	this( CodeSource source ) {
		this.source = source;
	}

public:
	CodeSource source;
	/// Offset from the start of the sourceFile (the code begins there)
	size_t startPos;
	/// Length of the code segment
	size_t length;

public:
	pragma( inline ) @property const {
		size_t endPos( ) {
			return startPos + length;
		}

		size_t startLine( ) {
			return source && startPos ? source.lineNumberAt( startPos ) : 0;
		}

		size_t startColumn( ) {
			return source && startPos ? startPos - source.lineNumberStart( startLine ) : 0;
		}

		size_t endLine( ) {
			return source && startPos ? source.lineNumberAt( startPos + length ) : 0;
		}

		size_t endColumn( ) {
			return source && startPos ? endPos - source.lineNumberStart( endLine ) : 0;
		}

		string file( ) {
			return source.absoluteFilePath;
		}
	}

}
