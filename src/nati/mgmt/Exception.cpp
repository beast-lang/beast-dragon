#include "Exception.h"

namespace nati {

	void error( const String &identifier, const String &message ) {
		fprintf( stderr, "ERROR '%s': %s", identifier.c_str(), message.c_str() );
		throw Exception( identifier, message );
	}

	Exception::Exception( const String &identifier, const String &message ) :
		identifier( identifier ),
		message( message ) {
	}

	const char *Exception::what() const _GLIBCXX_NOEXCEPT {
		return message.c_str();
	}


}
