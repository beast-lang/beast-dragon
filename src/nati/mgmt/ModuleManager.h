#ifndef NATI_MODULEMANAGER_H
#define NATI_MODULEMANAGER_H

#include <string>
#include <nati/ast/AST_ExtendedIdentifier.h>

namespace nati {

	/**
	 * The ModuleManager is a class that keeps project's packages in track.
	 * It can also translate module names into actual filenames.
	 */
	class ModuleManager final {

	public:
		virtual ~ModuleManager() {}

	public:
		/**
		 * Returns filename of the module specified by the :identifier
		 *
		 * @param identifier Module identifier
		 * @return Location (relative to the main project directory) and filename of the desired module
		 */
		virtual std::string moduleFilename( AST_ExtendedIdentifier &identifier ) = 0;

	};

}

#endif //NATI_MODULEMANAGER_H
