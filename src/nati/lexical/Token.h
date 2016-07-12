#ifndef NATI_TOKEN_H
#define NATI_TOKEN_H

#include "Identifier.h"

namespace nati {

	enum class TokenType {
		none, ///< Erroreous state
		identifier,
		keyword,
		dot, ///< '.'
		eof
	};

	class Token final {

	public:
		void operator =( TokenType type );
		operator bool() const;

	public:
		TokenType type = TokenType::none;
		union {
			Identifier identifier;
			Keyword keyword;
		};

	};

}

#endif //NATI_TOKEN_H
