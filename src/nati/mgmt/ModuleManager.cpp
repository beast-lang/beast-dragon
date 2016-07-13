#include <regex>
#include "ModuleManager.h"

namespace nati {

	ModuleManager *moduleManager = nullptr;

	bool isNatiSourceFile( const String &filename ) {
		static const std::regex regex( "^(.*[\\\\/])?[a-zA-Z_0-9]\\.nati$" );
		return std::regex_match( filename, regex );
	}

}