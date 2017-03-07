module beast.core.task.context;

import beast.core.context;
import core.thread;
import beast.util.uidgen;
import beast.core.error.error;

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
		}

		~this( ) {
			if ( fiber_.state == Fiber.State.HOLD ) {
				synchronized ( this ) {
					isQuitting_ = true;
					fiber_.call( );
				}
			}

			assert( fiber_.state == Fiber.State.TERM );
		}

	public:
		/// Context this context is waiting for to do something (for circular reference checking)
		TaskContext blockingContext_;
		/// Identifiaction string of the task guard blocking this context (that is waiting for another task to finish)
		string delegate( ) blockingTaskGuardIdentificationString_;

	public:
		void setJob( Job job ) {
			synchronized ( this ) {
				assert( !job_ );

				fiber_.reset( );
				job_ = job;
				contextData_ = ContextData( );
				contextData_.jobId = jobIdGen( );
				contextData_.taskContext = this;
			}
		}

		/// Starts/continues executing assigned job
		void execute( ) {
			synchronized ( this ) {
				assert( job_ );

				fiber_.call( );
			}
		}

		/// Pauses execution of this context
		void yield( ) {
			assert( context.taskContext is this );

			contextData_ = context;
			context = ContextData.init;

			Fiber.yield( );

			context = contextData_;

			if ( isQuitting_ )
				throw new TaskContextQuittingException;

			if ( fiber_.state == Fiber.State.TERM )
				taskManager.reportIdleContext( this );
		}

	private:
		/// Job the context is currently executing
		Job job_;

	private:
		ContextData contextData_;
		Fiber fiber_;
		bool isQuitting_;

	private:
		void run( ) {
			import core.stdc.stdlib : exit, EXIT_FAILURE;
			import std.stdio : writeln, stderr;

			try {
				assert( job_ );

				context = contextData_;

				try {
					job_( );

					assert( !context.session, "Unfinished session" );
				}
				catch ( BeastErrorException exc ) {
					/// Do nothing, handled elsewhere
				}

				job_ = null;
				contextData_ = ContextData.init;
			}
			catch ( Throwable t ) {
				stderr.writeln( "UNCAUGHT EXCEPTION: ", t.toString );
				// Disgracefully shutdown the application
				exit( EXIT_FAILURE );
			}
		}

	private:
		static __gshared UIDGenerator jobIdGen;

}
