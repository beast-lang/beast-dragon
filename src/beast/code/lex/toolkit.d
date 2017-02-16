module beast.code.lex.toolkit;

public {
	import beast.toolkit;
	import beast.code.lex.identifier;
	import beast.code.lex.token;
}

import beast.code.lex.token;
import beast.code.lex.lexer;

pragma( inline ) {
	/// Context-local lexer instance
	Lexer lexer( ) {
		return context.lexer;
	}

	/// Current token of the current context lexer
	Token currentToken( ) {
		return lexer.currentToken;
	}

	/// Commands current context lexer to scan for next token and returns it
	Token getNextToken( ) {
		return lexer.getNextToken;
	}
}