#ifndef NATI_LEXER_H
#define NATI_LEXER_H

#include <sstream>
#include <nati/utility.h>
#include <nati/mgmt/Exception.h>
#include "LexerState.h"
#include "Token.h"

namespace nati {

	/**
	 * Well... a lexer. Based on a FSM.
	 */
	class Lexer final {
		friend class ExpectationGuard;

	public:
		/// Sets the source code to :source && resets the lexer
		void setSource( const String &source );

	public:
		/// Current token
		inline const Token &token() const;

	public:
		/// Returns if the current token is of type :type
		inline bool isToken( TokenType type, const String &expectationStr = "" );

	public:
		/// Throws an exception if current token is not of :type
		inline void expectToken( TokenType type, const String &expectationStr = "" );

	public:
		/// Processes one token and stores it (accessible via token())
		void nextToken();

	public:
		/**
		 * Equvalient to nextToken(); expectToken( type );
		 */
		inline void expectNextToken( TokenType type );

		void unexpectedTokenError();

	private:
		/**
		 * Registers that there was a check for a token (for error reporting)
		 */
		inline void registerExpectation( const String &tokenStr, const String &expectationStr );

	private:
		LexerState state_;
		/// String accumulator, used for identifiers, literals, etc.
		std::stringstream accumulator_;
		/// Last token parsed
		Token token_;
		/// Source code
		String source_;
		String::iterator sourceIterator_;

	private:
		/**
		 * List of top level tokens/grammar rules were checked for the current token. After obtaining a new token, the list is cleared.
		 */
		List< String > expectationList_;

	};

	extern __thread Lexer *lexer;

	const Token &Lexer::token() const {
		return token_;
	}

	bool Lexer::isToken( TokenType type, const String &expectationStr ) {
		registerExpectation( tokenTypeStr( type ), expectationStr );
		return token_.type == type;
	}

	void Lexer::expectToken( TokenType type, const String &expectationStr ) {
		if( !isToken( type, expectationStr ) )
			unexpectedTokenError();
	}

	void Lexer::expectNextToken( TokenType type ) {
		nextToken();
		expectToken( type );
	}

	void Lexer::registerExpectation( const String &tokenStr, const String &expectationStr ) {
		expectationList_.push_back( expectationStr.empty() ? tokenStr : ( expectationStr + " (beginning with " + tokenStr + ")" ) );
	}

}

#endif //NATI_LEXER_H
