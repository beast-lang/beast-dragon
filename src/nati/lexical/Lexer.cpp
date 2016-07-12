#include "Lexer.h"

namespace nati {

	__thread Lexer *lexer = nullptr;

	UnexpectedTokenException::UnexpectedTokenException( TokenType whatExpected ) {
		// TODO
	}


	void Lexer::setSource( const String &source ) {
		source_ = source + '\0';
		sourceIterator_ = source_.begin();
	}

	void Lexer::nextToken() {
		// Clear the accumulator
		accumulator_.str( String() );
		accumulator_.clear();

		token_.type = TokenType::none;

		state_ = LexerState::init;

		while( true ) {
			char ch = *sourceIterator_; ///< Currently processed character
			bool readNextChar = true;

			switch( state_ ) {

				case LexerState::init: {
					if( isalpha( ch ) || ch == '#' || ch == '_' ) {
						state_ = LexerState::identifierOrKeyword;
						accumulator_ << ch;
						break;
					}

					if( isspace( ch ) ) {
						break;
					}

					switch( ch ) {

						case '\0': {
							token_ = TokenType::eof;
							readNextChar = false;
							break;
						}

						case '.': {
							token_ = TokenType::dot;
							break;
						}

						default: {
							// TODO throw error
							break;
						}

					}
					break;
				}

				case LexerState::identifierOrKeyword: {
					if( isalnum( ch ) || ch == '_' ) {
						accumulator_ << ch;
						break;
					}

					Identifier ident( accumulator_.str() );
					if( ident.keyword() == Keyword::notAKeyword ) {
						token_ = TokenType::identifier;
						token_.identifier = ident;

					} else {
						token_ = TokenType::keyword;
						token_.keyword = ident.keyword();

					}
					readNextChar = false;
					break;
				}

			}

			if( readNextChar )
				sourceIterator_++;

			if( token_ )
				return;
		}
	}

}
