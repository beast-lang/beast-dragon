#include <nati/utility.h>
#include <nati/mgmt/TaskContext.h>
#include "TaskManager.h"

namespace nati {
	TaskManager *taskManager = nullptr;

	TaskManager::TaskManager() {

	}

	TaskManager::~TaskManager() {
		LockGuard l( mutex_ );

		isQuitting_ = true;

		// Wake all workers
		idleContextCondition_.notify_all();

		for( TaskContext *context : contextList_ )
			delete context;
	}

	void TaskManager::waitForTask( TaskGuard *task ) {
		// TODO
	}

	void TaskManager::notifyTaskIsFinished( TaskGuard *task ) {
		// TODO
	}

}
