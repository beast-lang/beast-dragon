module beast.code.lex.toolkit;

public {
	import beast.toolkit;
	import beast.code.lex.identifier;
	import beast.code.lex.token;
}

import beast.code.lex.token;
import beast.code.lex.lexer;

pragma( inline ) @property {
	/// Context-local lexer instance
	Lexer lexer( ) {
		return context.lexer;
	}

	Token currentToken( ) {
		return lexer.currentToken;
	}

	Token getNextToken( ) {
		return lexer.getNextToken;
	}
}
