module beast.lex.lexer;

import std.conv;
import beast.lex.token;
import beast.toolkit;
import beast.project.codesource;
import beast.lex.identifier;

/// Thread-local instance
Lexer lexer;

final class Lexer {

public:
	this( CodeSource source ) {
		source_ = source;
		line_ = 1;
	}

public:
	@property CodeSource source() {
		return source_;
	}

	/// Position in source file
	@property size_t pos( ) {
		return pos_;
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
		if ( pos_ >= source.content.length )
			return new Token( Token.Special.eof );

		State state = State.init;

		while ( true ) {
			currentChar_ = source_.content[ pos_ ];

			if ( currentChar_ == '\n' )
				line_++;

			final switch ( state ) {

			case State.init: {
					tokenStartPos_ = pos_;

					switch ( currentChar_ ) {

					case 'a': .. case 'z': // Identifier or keyword
					case 'A': .. case 'Z':
					case '#', '_': {
							state = State.identifierOrKeyword;
							stringAccumulator ~= currentChar_;
							pos_++;
						}
						break;

					case ' ', '\t', '\n': { // Whitespace
							pos_++;
						}
						break;

					default:
						error_unexpectedCharacter();

					}
				}
				break;

			case State.identifierOrKeyword: {
					switch ( currentChar_ ) {

					case 'a': .. case 'z': // Continuation of identifier/keyword
					case 'A': .. case 'Z':
					case '0': .. case '9':
					case '_': {
							stringAccumulator ~= currentChar_;
							pos_++;
						}
						break;

					default: {
							Identifier id = Identifier.obtain( stringAccumulator );
							stringAccumulator = null;
							state = State.init;

							return id.keyword == Token.Keyword._noKeyword ? new Token( id ) : new Token( id.keyword );
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
	void error_unexpectedCharacter( string file = __FILE__, size_t line = __LINE__ ) {
		berror( CodeLocation( source_, tokenStartPos_, pos_ - tokenStartPos_ ), BError.unexpectedCharacter, "Unexpected character: '%s' (%s)".format( currentChar_, currentChar_ ) );
	}

private:
	size_t pos_;
	size_t tokenStartPos_;
	size_t line_;
	Token currentToken_;
	char currentChar_;
	CodeSource source_;

private:
	string stringAccumulator;

private:
	enum State {
		init,
		identifierOrKeyword
	}

}
