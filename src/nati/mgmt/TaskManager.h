#ifndef NATI_TASKMANAGER_H
#define NATI_TASKMANAGER_H

#include <mutex>
#include <condition_variable>
#include <thread>
#include <vector>
#include <set>
#include "TaskGuard.h"

namespace nati {

	class TaskContext;

	using TaskManagerTask = std::function<void()>;

	class TaskManager final {
		friend class TaskContext;

	public:
		TaskManager();
		~TaskManager();

	public:
		/**
		 * Suspends the current worker fiber and marks it for waking up after :task is complete.
		 *
		 * @remark This function is thread-safe.
		 */
		void waitForTask( TaskGuard *task );

		/**
		 * Wakes all fibers that were working for the :task (doesn't have to happen immidiately).
		 * If no task is waiting, this function should not be called.
		 *
		 * @remark This function is thread-safe.
		 */
		void notifyTaskIsFinished( TaskGuard *task );

	private:
		bool isQuitting_ = false;

	private:
		/**
		 * Mutex for acessing contexts
		 */
		std::mutex mutex_;
		/**
		 * List of all contexts
		 */
		std::vector<TaskContext*> contextList_;
		/**
		 * Count of idle contexts that have nothing to do.
		 * @note Idle contexts are waiting on the idleContextCondition_
		 */
		size_t idleContextCount_ = 0;
		/**
		 * Count of currently running contexts.
		 */
		size_t runningContextCount_ = 0;
		/**
		 * Contexts that are idle are waiting on this condition. They're notified when they get a new job to do or when the program is quitting.
		 */
		std::condition_variable idleContextCondition_;
		/**
		 * A variable used for passing a task that should be run in a currently woken worker thread
		 */
		TaskManagerTask taskToBeRun_ = nullptr;

	};

	extern TaskManager *taskManager;

}

#endif //NATI_TASKMANAGER_H
