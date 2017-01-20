module beast.lex.token;

import beast.lex.toolkit;
import beast.project.sourcefile;

final class Token {

public:
	enum Type {
		_noToken,
		identifier,
		keyword,
		special
	}
	enum Special {
		eof,
		lBracket,
		rBracket,
		lBrace,
		rBrace,
		lParent,
		rParent
	}
public:
	this( Special special ) {
		this( );
		type = Type.special;
		data.special = special;
	}

	this( Identifier identifier ) {
		this( );
		type = Type.identifier;
		data.identifier = identifier;
	}

	this( Keyword keyword ) {
		this( );
		type = Type.keyword;
		data.keyword = keyword;
	}

public:
	SourceFile sourceFile;
	const size_t sourceFileOffset, length;
	const Type type;

public:
	@property Identifier identifier() {
		assert( type == Type.identifier );
		return data.identifier;
	}
	@property Keyword keyword() {
		assert( type == Type.keyword );
		return data.keyword;
	}
	@property Special special() {
		assert( type == Type.special );
		return data.special;
	}

private:
	this( ) {
		assert( lexer );

		sourceFileOffset = lexer.tokenStartPos;
		length = lexer.sourceFilePos;
		type = Type._noToken;
	}

private:
	union Data {
		Identifier identifier;
		Keyword keyword;
		Special special;
	}
	Data data;

}
