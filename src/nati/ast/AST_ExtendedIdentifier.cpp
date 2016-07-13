#include <nati/lexical/Lexer.h>
#include "AST_ExtendedIdentifier.h"

namespace nati {

	bool AST_ExtendedIdentifier::canParse() {
		return lexer->isToken( TokenType::identifier, "ExtendedIdentifier" );
	}
	const AST_ExtendedIdentifier* AST_ExtendedIdentifier::parse() {
		UniquePtr<AST_ExtendedIdentifier> result( new AST_ExtendedIdentifier() );

		lexer->expectToken( TokenType::identifier, "ExtendedIdentifier" );

		while( lexer->isToken( TokenType::dot ) ) {
			lexer->expectNextToken( TokenType::identifier );
			result->identifiers.push_back( lexer->token().identifier );
		}

		return result.release();
	}

	const String &AST_ExtendedIdentifier::str() {
		if( str_.empty() && !identifiers.empty() ) {
			int i = 0;
			for( const Identifier& id : identifiers ) {
				if( i ++ )
					str_.append( "." );

				str_.append( id.str() );
			}
		}

		return str_;
	}

}
