#ifndef NATI_LEXER_H
#define NATI_LEXER_H

#include <sstream>
#include <nati/utility.h>
#include "LexerState.h"
#include "Token.h"

namespace nati {

	class UnexpectedTokenException final : std::exception {

	public:
		UnexpectedTokenException( TokenType whatExpected );

	};

	/**
	 * Well... a lexer. Based on a FSM.
	 */
	class Lexer final {

	public:
		/// Sets the source code to :source && resets the lexer
		void setSource( const String &source );

	public:
		/// Current token
		const Token &token() const {
			return token_;
		}

	public:
		/// Returns if the current token is of type :type
		inline bool isToken( TokenType type ) const {
			return token_.type == type;
		}

	public:
		/// Throws an exception if current token is not of :type
		inline void expectToken( TokenType type ) const {
			if( token_.type != type )
				throw UnexpectedTokenException( type );
		}

	public:
		/// Processes one token and stores it (accessible via token())
		void nextToken();

	public:
		/**
		 * Equvalient to nextToken(); expectToken( type );
		 */
		inline void expectNextToken( TokenType type ) {
			nextToken();
			expectToken( type );
		}

	private:
		LexerState state_;
		/// String accumulator, used for identifiers, literals, etc.
		std::stringstream accumulator_;
		/// Last token parsed
		Token token_;
		/// Source code
		String source_;
		String::iterator sourceIterator_;

	};

	extern __thread Lexer *lexer;

}

#endif //NATI_LEXER_H
