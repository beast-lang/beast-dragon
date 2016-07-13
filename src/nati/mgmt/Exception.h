#ifndef NATI_EXCEPTION_H
#define NATI_EXCEPTION_H

#include <nati/utility.h>

namespace nati {

	/**
	 * Reports a compiler error and throws an Exception
	 */
	void error( const String &identifier, const String &message = "" );

	class Exception : public std::exception {
		friend void error( const String &identifier, const String &message );

	private:
		Exception( const String &identifier, const String &message );

	public:
		virtual const char *what() const _GLIBCXX_NOEXCEPT override;

	public:
		const String identifier;
		String message;

	};

}

#endif //NATI_EXCEPTION_H
