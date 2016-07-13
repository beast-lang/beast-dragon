#ifndef NATI_MODULEMANAGER_H
#define NATI_MODULEMANAGER_H

#include <nati/utility.h>
#include <nati/semantic/Module.h>

namespace nati {

	/**
	 * The ModuleManager is a class that keeps project's packages in track.
	 * It can also translate module names into actual filenames.
	 */
	class ModuleManager {

	public:
		virtual ~ModuleManager() { }

	public:
		/**
		 * Returns a module specified by the identifier.
		 * @note This function is thread-safe
		 *
		 * @param identifier Module identifier (AST_ExtendedIdentifier.str)
		 */
		virtual Module *module( String &identifier ) = 0;

		/**
		 * Returns a list of modules that are known to belong to the project before any parsing starts.
		 * @note In some scenarios, the final module list doesn't have to be same as the inital one - there might be a ModuleManager that adds modules to the project when they're attempted to be imported using import.
		 */
		virtual const List< Module * > &initialModuleList() = 0;

		/**
		 * Returns the final list of the modules that belong to the project.
		 * @note This function can be called only after code generation stage.
		 */
		virtual const List< Module * > &finalModuleList() = 0;

	};

	extern ModuleManager *moduleManager;

	/**
	 * Returns if filename matches the nati source file filter
	 */
	bool isNatiSourceFile( const String &filename );

}

#endif //NATI_MODULEMANAGER_H
