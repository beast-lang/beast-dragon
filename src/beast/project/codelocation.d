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
	@property size_t startLine( ) const {
		// TODO:
		return 0;
	}

	@property size_t startColumn( ) const {
		// TODO:
		return 0;
	}

	@property size_t endLine( ) const {
		// TODO:
		return 0;
	}

	@property size_t endColumn( ) const {
		// TODO:
		return 0;
	}

	@property string file( ) const {
		return source.absoluteFilePath;
	}

}
