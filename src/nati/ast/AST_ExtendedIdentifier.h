#ifndef NATI_AST_EXTENDEDIDENTIFIER_H
#define NATI_AST_EXTENDEDIDENTIFIER_H

#include <nati/lexical/Identifier.h>
#include "ASTItem.h"

namespace nati {

	/**
	 * ExtendedIdentifier ::= Identifier { '.' Identifier }
	 */
	class AST_ExtendedIdentifier final : public ASTItem {

	private:
		AST_ExtendedIdentifier() {};

	public:
		static bool canParse();
		static const AST_ExtendedIdentifier *parse();

	public:
		/**
		 * Returns string in format ident1.ident2.ident3. ...
		 */
		const String &str();

	public:
		List< Identifier > identifiers;

	private:
		String str_;

	};

}

#endif //NATI_AST_EXTENDEDIDENTIFIER_H
