#ifndef NATI_LEXER_H
#define NATI_LEXER_H

#include <sstream>
#include "LexerState.h"
#include "Token.h"

namespace nati {

	/**
	 * Well... a lexer. Based on a FSM.
	 */
	class Lexer {

	public:
		/// Sets the source code to :source && resets the lexer
		void setSource( const std::string &source );

	public:
		/// Current token
		const Token &token() const;

	public:
		/// Returns if the current token is of type :type
		bool isToken( TokenType type ) const;

	public:
		/// Throws an exception if current token is not of :type
		void expectToken( TokenType type ) const;

	public:
		/// Processes one token and stores it (accessible via token())
		void nextToken();

	private:
		LexerState state_;
		/// String accumulator, used for identifiers, literals, etc.
		std::stringstream accumulator_;
		/// Last token parsed
		Token token_;
		/// Source code
		std::string source_;
		std::string::iterator sourceIterator_;

	};

	extern __thread Lexer *lexer;

}

#endif //NATI_LEXER_H
