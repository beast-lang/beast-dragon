#include "ModuleManager_ProjectBased.h"
#include "Exception.h"
#include <boost/filesystem.hpp>
#include <regex>

namespace nati {

	Module *ModuleManager_ProjectBased::module( String &identifier ) {
		LockGuard l( mutex_ );

		auto it = moduleMap_.find( identifier );
		if( it == moduleMap_.end() )
			error( "moduleNotFound", "Module '" + identifier + "' not found in the project" );

		return it->second;
	}

	const List< Module * > &ModuleManager_ProjectBased::initialModuleList() {
		return initialModuleList_;
	}

	const List< Module * > &ModuleManager_ProjectBased::finalModuleList() {
		return initialModuleList_;
	}

	void ModuleManager_ProjectBased::loadRootDirectory( const String &absolutePath ) {
		boost::filesystem::recursive_directory_iterator iterator( absolutePath ), end;

		for( ; iterator != end; iterator++ ) {
			String filePath = iterator->path().string();
			if( !isNatiSourceFile( filePath ) )
				continue;

			/*String relativePath = iterator->path().relative_path().string();
			static const std::regex regex( "" );

			Module *module = new Module( filePath, );*/
		}
	}

}
