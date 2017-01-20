module beast.work.worker;

import core.thread;
import std.stdio;
import beast.context;
import beast.work.manager;
import beast.work.context;

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
				TaskContext task = context.workManager.askForAJob( );

				if ( !task ) {
					return;
				}

				// Execute the job
				task.execute( );
			}
		}
		catch( Throwable t ) {
			writeln( stderr, "Uncaught exception on worker thread: ", t.msg );
		}
	}
}
