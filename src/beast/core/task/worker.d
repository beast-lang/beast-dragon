module beast.core.task.worker;

import core.thread;
import std.stdio;
import beast.toolkit;
import beast.core.task.manager;
import beast.core.task.context;

final class Worker {

package:
	this( ) {
		thread_ = new Thread( &run );
		thread_.start( );
	}

package:
	void waitForEnd() {
		thread_.join();
	}

private:
	Thread thread_;

private:
	void run( ) {
		try {
			while ( true ) {
				TaskContext task = taskManager.askForAJob( );

				if ( !task ) {
					return;
				}

				// Execute the job
				task.execute( );
			}
		}
		catch( Throwable t ) {
			stderr.writeln( "UNCAUGHT EXCEPTION: " ~ t.toString );
		}
	}
}
