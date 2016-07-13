#ifndef NATI_KEYWORD_H
#define NATI_KEYWORD_H

#include <nati/utility.h>

namespace nati {

	enum class Keyword {
		notAKeyword, ///< Token is not a keyword
		this_,

		_cnt
	};

	const String &keywordStr( Keyword keyword );

}

#endif //NATI_KEYWORD_H
