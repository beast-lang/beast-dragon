#ifndef NATI_IDENTIFIER_H
#define NATI_IDENTIFIER_H

#include <nati/utility.h>
#include "IdentifierTable.h"

namespace nati {

	/**
	 * Class wrapping the 'Identifier' token.
	 * Identifier ::= #?[a-zA-Z_][a-zA-Z_0-9]*
	 */
	class Identifier final {

	public:
		Identifier();
		Identifier( const String &str );
		Identifier( const Identifier &other );

	public:
		const String &str() const;

		Keyword keyword() const;

	public:
		bool operator==( const Identifier &other ) const;

	private:
		const IdentifierTableRecord *ptr_;

	};

}


#endif //NATI_IDENTIFIER_H
