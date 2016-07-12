#ifndef NATI_TASKGUARD_H
#define NATI_TASKGUARD_H

#include <cstdint>
#include <atomic>

#include "TaskManager.h"

namespace nati {

	/**
	 * TaskGuard is a class that wraps functionality of keeping info about a certain task (for example parsing a file, compiling some part of code, ...)
	 * It keeps track if the task is done or in WIP, and using its functionality, it ensures that a task gets done only once.
	 */
	class TaskGuard final {

	private:
		using Flags = std::uint8_t;
		enum class Flag : Flags {
			done = 1 << 0, ///< Task is done
			wip = 1 << 1, ///< Task is being worked on
			waiting = 1 << 2, ///< Someone is waiting for the task to finish
		};

	public:
		TaskGuard() {
			flags_ = 0;
		}

	public:
		/**
		 * Returns if the task is finished.
		 *
		 * @note This function is thread-safe.
		 */
		inline bool isFinished() const {
			return flags_ & (Flags) Flag::done;
		}

	public:
		/**
		 * Returns true if the task is already done or marks the task as WIP and returns false.
		 * If this function returns false, you should do the task and then call markFinished()
		 */
		inline bool returnIsDoneOrStart() {
			Flags flags = flags_.fetch_or( (Flags) Flag::wip );

			// If the task is done, return true
			if( flags & (Flags) Flag::done )
				return true;

			if( flags & (Flags) Flag::wip ) {
				flags = flags_.fetch_or( (Flags) Flag::waiting );

				// The task might have been finished between the last fetch and that waiting one, so we have to check that
				if( flags & (Flags) Flag::done )
					return true;

				taskManager->waitForTask( this );
				return true;
			}

			return false;
		}

		inline void markFinished() {
			Flags flags = flags_.fetch_or( (Flags) Flag::done );

			if( flags & (Flags) Flag::waiting )
				taskManager->notifyTaskIsFinished( this );
		}

	private:
		std::atomic< Flags > flags_{ 0 };

	};

}

#endif //NATI_TASKGUARD_H
