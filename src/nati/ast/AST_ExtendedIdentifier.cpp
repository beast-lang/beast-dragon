#include <nati/lexical/Lexer.h>
#include "AST_ExtendedIdentifier.h"

namespace nati {

	bool AST_ExtendedIdentifier::canParse() {
		return lexer->isToken( TokenType::identifier );
	}
	AST_ExtendedIdentifier* AST_ExtendedIdentifier::parse() {
		lexer->expectToken( TokenType::identifier );

		std::vector< Identifier > result;
		while( lexer->isToken( TokenType::identifier ) ) {
			result.push_back( lexer->token().identifier );
			// TODO
		}

		return new AST_ExtendedIdentifier( std::move( result ) );
	}

	AST_ExtendedIdentifier::AST_ExtendedIdentifier( std::vector< Identifier > &&identifiers ) : identifiers( identifiers ) {

	}

}
