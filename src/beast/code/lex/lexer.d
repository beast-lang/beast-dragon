module beast.code.lex.lexer;

import std.conv;
import beast.code.lex.token;
import beast.toolkit;
import beast.core.project.codesource;
import beast.code.lex.identifier;

/// Thread-local instance
Lexer lexer;

final class Lexer {

public:
	this( CodeSource source ) {
		source_ = source;
		line_ = 1;
	}

public:
	@property CodeSource source( ) {
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
	Token getNextToken( ) {
		Token result = _getNextToken( );
		currentToken_ = result;
		return result;
	}

	private Token _getNextToken( ) {
		assert( context.lexer is this );

		const auto _gd = ErrorGuard( CodeLocation( source_, tokenStartPos_, pos_ - tokenStartPos_ ) );

		State state = State.init;

		while ( true ) {
			currentChar_ = pos_ < source_.content.length ? source_.content[ pos_ ] : 0;

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

					case '.': {
							pos_++;
							return new Token( Token.Special.dot );
						}

					case ';': {
							pos_++;
							return new Token( Token.Special.semicolon );
						}

					case '@': {
							pos_++;
							return new Token( Token.Special.at );
						}

					case 0: {
							return new Token( Token.Special.eof );
						}

					default:
						error_unexpectedCharacter( );

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
		berror( E.unexpectedCharacter, "Unexpected character: '%s'".format( currentChar_, currentChar_ ) );
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
