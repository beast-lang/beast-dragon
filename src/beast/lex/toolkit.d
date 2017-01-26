module beast.lex.toolkit;

public {
	import beast.toolkit;
	import beast.lex.identifier;
	import beast.lex.token;
}

import beast.lex.token;
import beast.lex.lexer;

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
