module beast.core.task.worker;

import core.thread : Thread;
import beast.core.context;
import beast.core.task.context;

final class Worker {

	public:
		static Worker current;

	package:
		this( size_t id ) {
			thread_ = new Thread( &run );
			thread_.start( );
			id_ = id;
		}

	public:
		size_t id( ) {
			return id_;
		}

	package:
		void waitForEnd( ) {
			thread_.join( );
		}

	private:
		Thread thread_;
		size_t id_;

	private:
		void run( ) {
			import core.stdc.stdlib : exit;
			import std.stdio : stderr, writeln;

			current = this;

			try {
				while ( true ) {
					TaskContext task = taskManager.askForAJob( );

					if ( !task )
						return;

					// Execute the job
					task.execute( );
				}
			}
			catch ( Throwable t ) {
				stderr.writeln( "UNCAUGHT EXCEPTION: " ~ t.toString );
				// Disgracefully shutdown the application
				exit( 5 );
			}
		}
}
