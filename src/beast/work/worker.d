module beast.work.worker;

import core.thread;
import beast.context;
import beast.work.manager;
import beast.work.context;

final class Worker {

package:
	this( ) {
		thread_ = new Thread( &run );
		thread_.start( );
	}

private:
	Thread thread_;

private:
	void run( ) {
		while ( true ) {
			TaskContext task = context.workManager.askForAJob( );

			if ( !task )
				return;

			// Execute the job
			task.execute( );
		}
	}
}
