#ifndef NATI_LEXERSTATE_H
#define NATI_LEXERSTATE_H

namespace nati {

	/**
	 * Enum describing state of the Lexer FSM
	 */
	enum class LexerState {
		init,
		identifierOrKeyword
	};

}

#endif //NATI_LEXERSTATE_H
