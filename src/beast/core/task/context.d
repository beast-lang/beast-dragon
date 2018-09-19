module beast.core.task.context;

import beast.core.context;
import core.thread;
import beast.util.uidgen;
import beast.core.error.error;

//debug = jobs;

final class TaskContextQuittingException : Exception {
	public this() {
		super("Context quitting");
	}
}

final class TaskContext {

public:
	alias Job = void delegate();

public:
	this() {
		fiber_ = new Fiber(&run, 2000000);
	}

	void uninitialize() {
		synchronized (this) {
			if (fiber_.state == Fiber.State.HOLD) {
				isQuitting_ = true;
				fiber_.call();
			}

			assert(fiber_.state == Fiber.State.TERM);
		}
	}

public:
	/// Context this context is waiting for to do something (for circular reference checking)
	TaskContext blockingContext_;
	/// Identifiaction string of the task guard blocking this context (that is waiting for another task to finish)
	string delegate() blockingTaskGuardIdentificationString_;

	ContextData contextData() {
		return contextData_;
	}

public:
	void setJob(Job job) {
		synchronized (this) {
			assert(!job_);

			fiber_.reset();
			job_ = job;
			contextData_ = new ContextData();
			contextData_.jobId = jobIdGen();
			contextData_.taskContext = this;
		}
	}

	/// Starts/continues executing assigned job
	void execute() {
		synchronized (this) {
			debug (jobs) {
				import std.stdio : stderr;

				auto id = contextData.jobId;
				stderr.writefln("start %s", id);
			}

			assert(job_);

			fiber_.call();

			debug (jobs)
				stderr.writefln("stop %s", id);
		}
	}

	/// Pauses execution of the current context context
	void yield() {
		assert(context.taskContext is this);

		contextData_ = context;
		context = null;

		Fiber.yield();

		context = contextData_;

		if (isQuitting_)
			throw new TaskContextQuittingException;

		if (fiber_.state == Fiber.State.TERM)
			taskManager.reportIdleContext(this);
	}

private:
	/// Job the context is currently executing
	Job job_;

private:
	ContextData contextData_;
	Fiber fiber_;
	bool isQuitting_;

private:
	void run() {
		import core.stdc.stdlib : exit, EXIT_FAILURE;
		import std.stdio : writeln, stderr;

		try {
			assert(job_);

			context = contextData_;

			try {
				job_();

				// Issue delayed jobs
				assert(!context.delayedIssuedJobsStack.length, "delayedIssuedJobsStack is not empty (should be popped by taskGuards)");
				foreach (job; context.delayedIssuedJobs)
					taskManager.imminentIssueJob(job);

				assert(!context.session, "Unfinished session");
			}
			catch (BeastErrorException exc) {
				/// Do nothing, handled elsewhere
			}

			job_ = null;
			contextData_ = null;
		}
		catch (Throwable t) {
			stderr.writeln("UNCAUGHT EXCEPTION: ", t.toString);
			// Disgracefully shutdown the application
			exit(EXIT_FAILURE);
		}
	}

public:
	static __gshared UIDGenerator jobIdGen;

private:
	debug ubyte status_;

}
