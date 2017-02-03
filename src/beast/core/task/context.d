module beast.core.task.context;

import core.thread;
import std.stdio;
import beast.toolkit;
import beast.core.task.guard;

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

public:
	/// Context this context is waiting for to do something (for circular reference checking)
	TaskContext blockingContext_;

public:
	void setJob( Job job ) {
		assert( !job_ );

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
			taskManager.reportIdleContext( this );
	}

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
		try {
			assert( job_ );

			context = contextData_;

			try {
				job_( );
			}
			catch( BeastErrorException exc ) {
				/// Do nothing, handled elsewhere
			}

			job_ = null;
			contextData_ = ContextData.init;
		}
		catch ( Throwable t ) {
			stderr.writeln( "UNCAUGHT EXCEPTION: ", t.toString );
		}
	}

}
