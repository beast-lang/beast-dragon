module beast.core.project.codelocation;

import beast.toolkit;
import beast.core.project.codesource;
import std.typecons : Rebindable;
import beast.core.error.guard;
import beast.code.lex.token;
import beast.code.lex.lexer;

/// Structure storing information of where a code segment is located in the source code files
struct CodeLocation {

public:
	this(const CodeSource source, size_t startPos, size_t length) {
		this.source = source;
		this.startPos = startPos;
		this.length = length;
	}

	this(const CodeSource source) {
		this.source = source;
	}

public:
	Rebindable!(const CodeSource) source;
	/// Offset from the start of the sourceFile (the code begins there)
	size_t startPos = -1;
	/// Length of the code segment
	size_t length;

public:
	pragma(inline) const {
		size_t endPos() {
			return startPos + length;
		}

		size_t startLine() {
			return source && startPos != -1 ? source.lineNumberAt(startPos) : 0;
		}

		size_t startColumn() {
			return source && startPos != -1 ? startPos - source.lineNumberStart(startLine) : 0;
		}

		size_t endLine() {
			return source && startPos != -1 ? source.lineNumberAt(startPos + length) : 0;
		}

		size_t endColumn() {
			return source && startPos != -1 ? endPos - source.lineNumberStart(endLine) : 0;
		}

		string file() {
			return source ? source.absoluteFilePath : null;
		}

		string content() {
			assert(source);
			return source.content[startPos .. endPos];
		}

		string shortContent() {
			// TODO: shortening
			assert(source);
			return source.content[startPos .. endPos];
		}
	}

public:
	/// Returns if this code location if subset of other code location
	bool isInside(const ref CodeLocation other) const {
		return source is other.source && startPos >= other.startPos && endPos <= other.endPos;
	}

public:
	/// Convenient error guard function
	ErrorGuardFunction errGuardFunction() {
		// We must copy the struct data, because the struct might not exists when the guard function is called (because of stack)
		// So this copy actually makes sense!
		CodeLocation data = this;
		return (msg) { msg.codeLocation = data; };
	}

public:
	bool opCast(T : bool)() const {
		return source !is null;
	}

}

/// Struct for watching code location, marks start with construction (call function codeLocationGuard), end with get
struct CodeLocationGuard {

public:
	@disable this();

public:
	CodeLocation get() {
		CodeLocation startLocation = startToken.codeLocation;
		CodeLocation endLocation = (lexer.currentToken is startToken ? startToken : lexer.currentToken.previousToken).codeLocation;
		assert(startLocation.source is endLocation.source);
		assert(startLocation.startPos <= endLocation.endPos);

		return CodeLocation(startLocation.source, startLocation.startPos, endLocation.endPos - startLocation.startPos);
	}

private:
	this(Token startToken) {
		this.startToken = startToken;
	}

private:
	Token startToken;

}

pragma(inline) CodeLocationGuard codeLocationGuard() {
	return CodeLocationGuard(lexer.currentToken);
}
