#include "Keyword.h"

namespace nati {

	const String &keywordStr( Keyword keyword ) {
		static const String array[] = {
			"(not a keyword)",
		  "this"
		};

		return array[int(keyword)];
	}

}

