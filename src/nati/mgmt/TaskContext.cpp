#include "TaskContext.h"
#include <nati/mgmt/TaskManager.h>
#include <nati/utility.h>

namespace nati {

	__thread TaskContext *currentContext = nullptr;

	TaskContext::TaskContext() {
		thread_ = std::thread( std::bind( &contextProcedure, this ) );
	}

	TaskContext::~TaskContext() {
		thread_.join();
	}

	TaskContext *TaskContext::current() {
		return currentContext;
	}

	void TaskContext::contextProcedure() {
		currentContext = this;

		TaskManagerTask task = nullptr;

		while( true ) {
			// Obtain a task
			while( true ) {
				LockGuard l( taskManager->mutex_ );

				if( task )
					taskManager->runningContextCount_--;

				if( taskManager->isQuitting_ )
					goto outerLoopEnd;

				task = taskManager->taskToBeRun_;
				taskManager->taskToBeRun_ = nullptr;

				if( task ) {
					taskManager->runningContextCount_++;
					break;
				}

				taskManager->idleContextCount_++;
				taskManager->idleContextCondition_.wait( l );
				taskManager->idleContextCount_--;
			}

			task();
		}
		outerLoopEnd:

		currentContext = nullptr;
	}

}
