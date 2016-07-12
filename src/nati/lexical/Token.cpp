#include "Token.h"

namespace nati {

	void Token::operator=( TokenType type ) {
		this->type = type;
	}

	Token::operator bool() const {
		return type != TokenType::none;
	}

}
