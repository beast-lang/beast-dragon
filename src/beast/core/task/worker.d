module beast.core.task.worker;

import core.thread : Thread;
import beast.core.context;
import beast.core.task.context;

final class Worker {

	package:
		this( ) {
			thread_ = new Thread( &run );
			thread_.start( );
		}

	package:
		void waitForEnd( ) {
			thread_.join( );
		}

	private:
		Thread thread_;

	private:
		void run( ) {
			import core.stdc.stdlib : exit, EXIT_FAILURE;
			import std.stdio : stderr, writeln;

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
				exit( EXIT_FAILURE );
			}
		}
}
