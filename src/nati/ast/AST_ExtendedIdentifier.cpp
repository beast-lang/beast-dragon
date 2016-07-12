#include <nati/lexical/Lexer.h>
#include "AST_ExtendedIdentifier.h"

namespace nati {

	bool AST_ExtendedIdentifier::canParse() {
		return lexer->isToken( TokenType::identifier );
	}
	const AST_ExtendedIdentifier* AST_ExtendedIdentifier::parse() {
		UniquePtr<AST_ExtendedIdentifier> result( new AST_ExtendedIdentifier() );

		lexer->expectToken( TokenType::identifier );

		while( lexer->isToken( TokenType::dot ) ) {
			lexer->expectNextToken( TokenType::identifier );
			result->identifiers.push_back( lexer->token().identifier );
		}

		return result.release();
	}

}
