module beast.project.codelocation;

import beast.project.sourcefile;

/// Structure storing information of where a code segment is located in the source code files
struct CodeLocation {

public:
	SourceFile sourceFile;
	/// Offset from the start of the sourceFile (the code begins there)
	size_t startPos;
	/// Length of the code segment
	size_t length;

public:
	@property size_t line() {
		// TODO:
		assert(0);
	}
	@property size_t lineOffset() {
		// TODO:
		assert(0);
	}
	@property string sourceFilePath() {
		return sourceFile.absoluteFilePath;
	}

}
