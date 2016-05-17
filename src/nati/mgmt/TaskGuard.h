#ifndef NATI_TASKGUARD_H
#define NATI_TASKGUARD_H

#include <cstdint>
#include <atomic>

namespace nati {

	class TaskGuard {

	private:
		using Flags = std::uint8_t;
		enum class Flag : Flags {
			done    = 1 << 0, ///< Task is done
			wip     = 1 << 1, ///< Task is being worked on
			waiting = 1 << 2, ///< Someone is waiting for the task to finish
		};

	public:
		TaskGuard();

	public:
		/**
		 * Returns if the task is finished.
		 *
		 * @remark This function is thread-safe.
		 */
		bool isFinished() const;

	public:
		/**
		 * Returns true if the task is already done or marks the task as WIP and returns false.
		 * If this function returns false, you should do the task and then call markFinished()
		 */
		bool returnIsDoneOrStart();
		void markFinished();

	private:
		std::atomic<Flags> flags_;

	};

}

#endif //NATI_TASKGUARD_H
