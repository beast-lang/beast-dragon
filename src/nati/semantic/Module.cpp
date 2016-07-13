#include "Module.h"

namespace nati {

	Module::Module( const String &filename, const String &expectedIdentifier ) :
		filename_( filename ),
		expectedIdentifier_( expectedIdentifier ) {

	}

	const String &Module::filename() const {
		return filename_;
	}

	const String &Module::identifier() const {
		return identifier_;
	}

}
