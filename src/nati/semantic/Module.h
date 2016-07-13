#ifndef NATI_MODULE_H
#define NATI_MODULE_H

#include <nati/utility.h>

namespace nati {

	class Module final {

	public:
		/**
		 * @param filename Absolute filename of the module file
		 * @param identifier Expected identifier of the module. After parsing the module, it is checked againts this. Can be null.
		 */
		Module( const String &filename, const String &expectedIdentifier );

	public:
		const String &filename() const;

		const String &identifier() const;

	private:
		const String filename_, identifier_, expectedIdentifier_;

	};

}

#endif //NATI_MODULE_H
