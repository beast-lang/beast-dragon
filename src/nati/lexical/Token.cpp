#include "Token.h"

namespace nati {

	Token::operator bool() const {
		return type != TokenType::none;
	}

}
