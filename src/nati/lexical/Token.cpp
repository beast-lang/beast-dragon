#include "Token.h"

namespace nati {

	const String &tokenTypeStr( TokenType tokenType ) {
		static const String array[] = {
			"(none)",
			"identifier",
			"keyword",
			"'.'",
			"EOF",
		};

		return array[ int( tokenType ) ];
	}

	String Token::str() const {
		switch( type ) {

			case TokenType::identifier:
				return "identifier '" + identifier.str() + "'";

			case TokenType::keyword:
				return "keyword '" + keywordStr( keyword ) + "'";

			default:
				return tokenTypeStr( type );

		}
	}

	void Token::operator=( TokenType type ) {
		this->type = type;
	}

	Token::operator bool() const {
		return type != TokenType::none;
	}

}
