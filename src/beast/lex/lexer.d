module beast.lex.lexer;

import std.conv;
import beast.lex.token;
import beast.toolkit;
import beast.project.sourcefile;
import beast.lex.identifier;
import beast.lex.keyword;

/// Thread-local instance
Lexer lexer;

final class Lexer {

public:
	this( SourceFile sourceFile ) {
		sourceFile_ = sourceFile;
		line_ = 1;
	}

public:
	@property SourceFile sourceFile( ) {
		return sourceFile_;
	}

	/// Position in source file
	@property size_t sourceFilePos( ) {
		return sourceFilePos_;
	}

	/// The last parsed token
	@property Token currentToken( ) {
		return currentToken_;
	}

	/// Parses next token from the source file
	Token getNextToken( )
	in {
		assert( context.lexer is this );
	}
	body {
		if ( sourceFilePos_ >= sourceFile.content.length )
			return new Token( Token.Special.eof );

		const auto errorCtx = ErrorContext( [  //
				"file" : sourceFile.absoluteFilePath, //
				"position" : sourceFilePos.to!string, //
				"line" : line_.to!string //
				 ] );
		State state = State.init;

		while ( true ) {
			char currentChar = sourceFile_.content[ sourceFilePos_ ];

			if ( currentChar == '\n' )
				line_++;

			final switch ( state ) {

			case State.init: {
					tokenStartPos_ = sourceFilePos_;

					switch ( currentChar ) {

					case 'a': .. case 'z':
					case 'A': .. case 'Z':
					case '#': {
							state = State.identifierOrKeyword;
							stringAccumulator ~= currentChar;
							sourceFilePos_++;
						}
						break;

					case ' ':
					case '\t':
					case '\n': {
							sourceFilePos_++;
						}
						break;

					default:
						berror( "Unexpected character: '%s' (%s)", currentChar, currentChar.to!int );

					}
				}
				break;

			case State.identifierOrKeyword: {
					switch ( currentChar ) {

					case 'a': .. case 'z':
					case 'A': .. case 'Z':
					case '0': .. case '9':
					case '_': {
							stringAccumulator ~= currentChar;
							sourceFilePos_++;
						}
						break;

					default: {
							Identifier id = Identifier.obtain( stringAccumulator );
							stringAccumulator = null;
							state = State.init;

							return id.keyword == Keyword._noKeyword ? new Token( id ) : new Token( id.keyword );
						}

					}

				}
				break;

			}
		}

		assert( 0 );
	}

package:
	@property size_t tokenStartPos( ) {
		return tokenStartPos_;
	}

private:
	size_t sourceFilePos_;
	size_t tokenStartPos_;
	size_t line_;
	Token currentToken_;
	SourceFile sourceFile_;

private:
	string stringAccumulator;

private:
	enum State {
		init,
		identifierOrKeyword
	}

}
