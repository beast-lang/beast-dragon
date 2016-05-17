#ifndef NATI_TASKMANAGER_H
#define NATI_TASKMANAGER_H

#include "TaskGuard.h"

namespace nati {

	class TaskManager {

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

	};

	extern TaskManager *taskManager;

}

#endif //NATI_TASKMANAGER_H
