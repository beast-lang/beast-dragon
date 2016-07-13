#ifndef NATI_MODULEMANAGER_PROJECTBASED_H
#define NATI_MODULEMANAGER_PROJECTBASED_H

#include "ModuleManager.h"

namespace nati {

	class ModuleManager_ProjectBased final : public ModuleManager {

	public:
		/**
		 * Throws an exception when module not found
		 */
		virtual Module *module( String &identifier ) override;

		virtual const List< Module * > &initialModuleList() override;

		virtual const List< Module * > &finalModuleList() override;

	public:
		/**
		 * Adds all modules from the directory to the project. Module names have to match the file-directory structure.
		 */
		void loadRootDirectory( const String& absolutePath );

	private:
		/**
		 * Mutex for finalModuleList_ and moduleMap_
		 */
		Mutex mutex_;
		List< Module * > initialModuleList_;
		Map< String, Module * > moduleMap_;

	};

}

#endif //NATI_MODULEMANAGER_PROJECTBASED_H
