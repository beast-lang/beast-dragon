#ifndef NATI_AST_EXTENDEDIDENTIFIER_H
#define NATI_AST_EXTENDEDIDENTIFIER_H

#include <nati/lexical/Identifier.h>
#include <vector>

namespace nati {

	/**
	 * ExtendedIdentifier ::= Identifier { '.' Identifier }
	 */
	class AST_ExtendedIdentifier final {

	private:
		AST_ExtendedIdentifier() {};

	public:
		static bool canParse();
		static const AST_ExtendedIdentifier *parse();

	public:
		List< Identifier > identifiers;

	};

}

#endif //NATI_AST_EXTENDEDIDENTIFIER_H
