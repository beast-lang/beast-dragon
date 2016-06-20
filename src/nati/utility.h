#ifndef NATI_UTILITY_H
#define NATI_UTILITY_H

#include <mutex>
#include <cstdarg>

#define __LINE_STR__ __LINE_STR2__(__LINE__)
#define __LINE_STR2__(x) __LINE_STR3__(x)
#define __LINE_STR3__(x) #x

using LockGuard = std::unique_lock<std::mutex>;

/**
 * "Condition should be true, otherwise something is wrong."
 * Used for debugging purposes (condition is not checked in the runtime)
 */
inline void assert( bool condition, const char *msg = "Assertion failed in file '" __FILE__ "' on line " __LINE_STR__, ... ) {
	if( condition )
		return;

	va_list vl;
	va_start( vl, msg );
	vfprintf( stderr, msg, vl );
	va_end( vl );
}

#endif //NATI_UTILITY_H
