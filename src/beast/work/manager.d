module beast.work.manager;

import core.sync.condition;
import core.sync.mutex;
import std.range;
import beast.work.worker;
import beast.work.context;

final class WorkManager {

public:
	enum workerCount = 32;

public:
	this( ) {
		plannedTasksMutex_ = new Mutex( );
		idleContextsMutex_ = new Mutex( );
		plannedTasksCondition_ = new Condition( plannedTasksMutex_ );

		// Spawn workers
		foreach ( i; 0 .. workerCount )
			workers_ ~= new Worker( );
	}

public:
	void issueTask( TaskContext context ) {
		synchronized ( plannedTasksMutex_ )
			plannedTasks_ ~= context;

		plannedTasksCondition_.notify( );
	}

package:
	/// A function called by Worker, returns task context to be executes or waits or a condition or returns null (signals quitting)
	TaskContext askForAJob( ) {
		synchronized ( plannedTasksMutex_ ) {
			idleWorkerCount_++;

			// Wait for a job
			while ( true ) {
				if ( isQuitting_ ) {
					idleWorkerCount_--;
					return null;
				}

				if ( plannedTasks_.length ) {
					TaskContext task = plannedTasks_.front( );
					plannedTasks_.popFront( );
					idleWorkerCount_--;
					return task;
				}
				// TODO: Possible jobs

				plannedTasksCondition_.wait( );
			}
		}
	}

	/// Called by TaskContext after task context job ends so it can be reused again
	void reportIdleContext( TaskContext context ) {
		synchronized ( idleContextsMutex_ )
			idleContexts_ ~= context;
	}

private:
	TaskContext[ ] plannedTasks_, idleContexts_;
	/// List of possible jobs
	TaskContext.Job[ ] possibleJobs_;
	Mutex plannedTasksMutex_, idleContextsMutex_;
	Condition plannedTasksCondition_;
	size_t idleWorkerCount_;
	bool isQuitting_ = false;

private:
	Worker[ ] workers_;

}
