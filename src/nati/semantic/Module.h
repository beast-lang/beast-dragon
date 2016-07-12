#ifndef NATI_MODULE_H
#define NATI_MODULE_H

#include <nati/ast/AST_ExtendedIdentifier.h>

namespace nati {

	class Module final {

	public:
		/**
		 * @param filename Absolute filename of the module file
		 * @param identifier Expected identifier of the module. After parsing the module, it is checked againts this. Can be null.
		 */
		Module( const String &filename, const AST_ExtendedIdentifier *expectedIdentifier );

	public:
		const String &filename() const;

		const AST_ExtendedIdentifier &identifier() const;

	private:
		const String filename_;
		const AST_ExtendedIdentifier *identifier_, *expectedIdentifier_;

	};

}

#endif //NATI_MODULE_H
