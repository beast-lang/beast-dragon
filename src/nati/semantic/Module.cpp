#include "Module.h"

namespace nati {

	Module::Module( const String &filename, const AST_ExtendedIdentifier *expectedIdentifier ) :
		filename_( filename ),
		expectedIdentifier_( expectedIdentifier ) {

	}

	const String &Module::filename() const {
		return filename_;
	}

	const AST_ExtendedIdentifier &Module::identifier() const {
		return *identifier_;
	}

}
