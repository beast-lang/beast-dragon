#include "TaskGuard.h"
#include "TaskManager.h"

namespace nati {

	TaskGuard::TaskGuard() {
		flags_ = 0;
	}

	bool TaskGuard::isFinished() const {
		return flags_ & (Flags) Flag::done;
	}

	bool TaskGuard::returnIsDoneOrStart() {
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

	void TaskGuard::markFinished() {
		Flags flags = flags_.fetch_or( (Flags) Flag::done );

		if( flags & (Flags) Flag::waiting )
			taskManager->notifyTaskIsFinished( this );
	}

}
