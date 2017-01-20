module beast.work.guard;

import core.atomic;
import core.sync.mutex;
import std.typecons;
import beast.toolkit;
import beast.utility.identifiable;
import beast.work.context;

/// Task guard is a base of beasts multithreaded compiling. For each task (parsing, generating code, everything) is keeps track of if it is done, handles waiting for tasks to finish and dependency loops
struct TaskGuard {

public:
	@disable this( );
	this( string identifier, Identifiable owner ) {
		this.identifier = identifier;
		this.owner = owner;
	}

public:
	const string identifier;
	const Identifiable owner;

public:
	/// If the task is done, returns true, otherwise it starts processing it (or waits till it's done)
	bool startWorkingOrReturnTrue( ) {
		const ubyte initialData = atomicOrData( Flags.workInProgress );

		// Task is already done, no problem
		if ( initialData & Flags.done )
			return true;

		// If not, we have to check if it is work in progress
		if ( initialData & Flags.workInProgress ) {
			dependentsMutex.lock( );

			// Mark that there are tasks waiting for it
			const ubyte wipData = atomicOrData( Flags.dependentTasksWaiting );

			// It is possible that the task was finished between initialData and wipData fetches, we need to check for that
			if ( wipData & Flags.done ) {
				dependentsMutex.unlock( );
				return true;
			}

			// Check for circular depedencies
			{
				TaskContext ctx = context_;
				const TaskContext thisContext = context.taskContext;
				TaskGuard* guard = ctx.blockingTaskGuard_;

				while ( guard ) {
					// The context is not set atomically, so we have to check for that
					while( !( guard.data_ & Flags.contextSet ) ) {}
					ctx = guard.context_;

					if ( ctx is thisContext )
						berror( "Circular dependency loop" ); // TODO: Better error message

					guard = ctx.blockingTaskGuard_;
				}
			}

			// Mark current context as waiting on this task	
			context.taskContext.blockingTaskGuard_ = &this;

			TaskContext[ ]* lstPtr = &this in dependents;
			if ( lstPtr )
				*lstPtr ~= context.taskContext;
			else
				dependents[ &this ] = [ context.taskContext ];

			// Yield the current context (we have to unlock dependentsMutex after yielding)
			context.taskContext.yield( { dependentsMutex.unlock( ); } );

			assert( data_ & Flags.done );

			synchronized ( dependentsMutex )
				context.taskContext.blockingTaskGuard_ = null;

			// After this context is resumed, the task should be done
			return true;
		}

		context_ = context.taskContext;
		atomicOrData( Flags.contextSet );

		return false;
	}

	void finish( ) {
		assert( data_ & Flags.workInProgress && !( data_ & Flags.done ) );

		const ubyte data = atomicOrData( Flags.done );

		// If there were tasks waiting for this guard, issue them
		if ( data & Flags.dependentTasksWaiting ) {
			synchronized ( dependentsMutex ) {
				assert( &this in dependents );

				foreach ( task; dependents[ &this ] )
					context.workManager.issueTask( task );

				// Clear dependent list
				dependents.remove( &this );
			}
		}
	}

private:
	enum Flags : ubyte {
		done = 1 << 0,
		workInProgress = 1 << 1,
		dependentTasksWaiting = 1 << 2,
		contextSet = 1 << 3,
		error = 1 << 4
	}

private:
	shared ubyte data_ = 0;
	/// Context that is working on this task
	TaskContext context_;

private:
	/// Ors the data_ with the orMask and returns its previous value
	ubyte atomicOrData( ubyte orMask ) {
		ubyte get, set;
		do {
			get = set = atomicLoad!( MemoryOrder.raw )( data_ );
			set |= orMask;
		}
		while ( !cas( &data_, get, set ) );

		return get;
	}
}

private {
	static __gshared Mutex dependentsMutex;
	/// Map of contexts that are waiting for a given task guard
	static __gshared TaskContext[ ][ TaskGuard*  ] dependents;

	enum _init = HookAppInit.hook!({
		dependentsMutex = new Mutex;
	});
}
