module beast.work.manager;

import core.sync.condition;
import core.sync.mutex;
import std.range;
import std.algorithm;
import beast.work.worker;
import beast.work.context;

final class WorkManager {

public:
	enum workerCount = 32;

public:
	this( ) {
		workerSyncMutex_ = new Mutex( );
		idleContextsMutex_ = new Mutex( );
		idleWorkersCondition_ = new Condition( workerSyncMutex_ );
		everythingDoneCondition_ = new Condition( workerSyncMutex_ );
	}

public:
	void spawnWorkers( ) {
		assert( !workers_.length );

		// Spawn workers
		foreach ( i; 0 .. workerCount )
			workers_ ~= new Worker( );
	}

	void quitWorkers( ) {
		isQuitting_ = true;

		idleWorkersCondition_.notifyAll( );
		foreach ( worker; workers_ )
			worker.waitForEnd( );
	}

	/// Waits till all jobs and tasks are done
	void waitForEverythingDone( ) {
		synchronized ( workerSyncMutex_ ) {
			while ( true ) {
				if ( !plannedTasks_.length && !plannedJobs_.length && idleWorkerCount_ == workerCount )
					return;

				everythingDoneCondition_.wait( );
			}
		}
	}

	void issueTask( TaskContext context ) {
		synchronized ( workerSyncMutex_ )
			plannedTasks_ ~= context;

		idleWorkersCondition_.notify( );
	}

	void issueJob( TaskContext.Job job ) {
		synchronized ( workerSyncMutex_ )
			plannedJobs_ ~= job;
	}

package:
	/// A function called by Worker, returns task context to be executes or waits or a condition or returns null (signals quitting)
	TaskContext askForAJob( ) {
		synchronized ( workerSyncMutex_ ) {
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
				else if ( plannedJobs_.length ) {
					TaskContext.Job job = plannedJobs_.front;
					plannedJobs_.popFront( );

					TaskContext ctx = obtainContext( );
					ctx.setJob( job );
					return ctx;

				}
				else if ( idleWorkerCount_ == workerCount )
					everythingDoneCondition_.notifyAll( );

				idleWorkersCondition_.wait( );
			}
		}
	}

	/// Called by TaskContext after task context job ends so it can be reused again
	void reportIdleContext( TaskContext context ) {
		synchronized ( idleContextsMutex_ )
			idleContexts_ ~= context;
	}

private:
	/// Reuses context or creates a new one
	TaskContext obtainContext( ) {
		synchronized ( idleContextsMutex_ ) {
			if ( idleContexts_.length ) {
				TaskContext ctx = idleContexts_[ $ - 1 ];
				idleContexts_.length--;
				return ctx;
			}
		}

		return new TaskContext;
	}

private:
	// TODO: TaskContext priority based on how many other contexts are waiting for it
	TaskContext[ ] plannedTasks_, idleContexts_;
	/// List of planned jobs
	TaskContext.Job[ ] plannedJobs_;
	Mutex workerSyncMutex_, idleContextsMutex_;
	Condition idleWorkersCondition_, everythingDoneCondition_;
	size_t idleWorkerCount_;
	bool isQuitting_ = false;

private:
	Worker[ ] workers_;

}