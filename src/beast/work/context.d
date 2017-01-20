module beast.work.context;

import core.thread;
import beast.context;
import beast.work.guard;

final class TaskContextQuittingException : Exception {
	public this( ) {
		super( "Context quitting" );
	}
}

final class TaskContext {

public:
	alias Job = void delegate( );

package:
	this( ) {
		fiber_ = new Fiber( &run );
		contextData_.taskContext = this;
	}

	~this( ) {
		if ( fiber_.state == Fiber.State.HOLD ) {
			isQuitting_ = true;
			fiber_.call( );
		}

		assert( fiber_.state == Fiber.State.TERM );
	}

package:
	void setJob( Job job ) {
		assert( !job_ && fiber_.state == Fiber.State.TERM );

		fiber_.reset( );
		job_ = job;
	}
	/// Starts executing a new job
	void execute( ) {
		assert( job_ );

		fiber_.call( );

		if ( actionAfterYield_ )
			actionAfterYield_( );
	}

	/// Pauses execution of this context
	void yield( void delegate( ) actionAfterYield = null ) {
		assert( context.taskContext is this );

		contextData_ = context;
		context = ContextData.init;
		actionAfterYield_ = actionAfterYield;

		Fiber.yield( );

		context = contextData_;

		if ( isQuitting_ )
			throw new TaskContextQuittingException;

		if ( fiber_.state == Fiber.State.TERM )
			context.workManager.reportIdleContext( this );
	}

package:
	/// Task guard this context is waiting for, manipulated from TaskGuard with its mutex
	TaskGuard *blockingTaskGuard_;

private:
	/// Action that should be executed from the calling context
	void delegate( ) actionAfterYield_;
	/// Job the context is currently executing
	Job job_;

private:
	ContextData contextData_;
	Fiber fiber_;
	bool isQuitting_;

private:
	void run( ) {
		assert( job_ );

		context = contextData_;

		job_( );

		job_ = null;
		contextData_ = ContextData.init;
	}

}
