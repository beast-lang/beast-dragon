module beast.work.guard;

import core.sync.mutex;
import beast.toolkit;
import beast.utility.identifiable;
import beast.work.context;

// TODO: Documentation
alias TaskGuardId = shared ubyte*;

mixin template TaskGuard( string identifier, Type ) {
	static assert( is( typeof( this ) : Identifiable ), "TaskGuards can only be mixed into classes that implement Identifiable interface" );
	static assert( __traits( hasMember, typeof( this ), _taskGuard_obtainFunctionName ), "You must implement '" ~ Type.stringof ~ " " ~ typeof( this ).stringof ~ "." ~ _taskGuard_obtainFunctionName ~ "()'." );

	import beast.work.context : TaskContext;
	import beast.work.guard : TaskGuardId;

private:
	Type _taskGuard_data;
	shared ubyte _taskGuard_flags;

	/// Context this task is being processed in
	TaskContext _taskGuard_context;

	enum _taskGuard_obtainFunctionName = "obtain_" ~ identifier;

public:
	Type _taskGuard_func( ) {
		import beast.utility.atomic : atomicFetchThenOr, atomicStore;
		import beast.work.guard : Flags = TaskGuardFlags, taskGuardDependentsList, taskGuardResolvingMutex, ErrorPoisoningException;

		const ubyte initialFlags = atomicFetchThenOr( _taskGuard_flags, Flags.workInProgress );

		if ( initialFlags & Flags.error )
			throw new ErrorPoisoningException( );

		// Task is already done, no problem
		if ( initialFlags & Flags.done )
			return _taskGuard_data;

		// If not, we have to check if it is work in progress
		if ( initialFlags & Flags.workInProgress ) {
			// Wait for the worker context to mark itself to this guard
			while ( !( _taskGuard_flags & Flags.contextSet ) ) {
			}

			taskGuardResolvingMutex.lock( );

			// Mark that there are tasks waiting for it
			const ubyte wipFlags = atomicFetchThenOr( _taskGuard_flags, Flags.dependentTasksWaiting );

			// It is possible that the task finished/failed between initialFlags and wipFlags fetches, we need to check for that
			if ( wipFlags & Flags.error ) {
				taskGuardResolvingMutex.unlock( );
				throw new ErrorPoisoningException( );
			}

			if ( wipFlags & Flags.done ) {
				taskGuardResolvingMutex.unlock( );
				return _taskGuard_data;
			}

			// Check for circular depedencies
			{
				TaskContext ctx = _taskGuard_context;
				const TaskContext thisContext = context.taskContext;
				while ( ctx ) {
					if ( ctx is thisContext ) {
						taskGuardResolvingMutex.unlock( );
						berror( "Circular dependency loop" ); // TODO: Better error message
					}

					ctx = ctx.blockingContext_;
				}
			}

			// Mark current context to be woken when the task is finished
			TaskContext[ ]* lstPtr = _taskGuard_id in taskGuardDependentsList;
			if ( lstPtr )
				*lstPtr ~= context.taskContext;
			else
				taskGuardDependentsList[ _taskGuard_id ] = [ context.taskContext ];

			// Mark current context as waiting on this task	(for circular dependency checks)
			context.taskContext.blockingContext_ = _taskGuard_context;

			// Yield the current context (we have to unlock dependentsMutex after yielding, before could screw things up -- the context could be woken before yelding)
			context.taskContext.yield( { taskGuardResolvingMutex.unlock( ); } );

			synchronized ( taskGuardResolvingMutex )
				context.taskContext.blockingContext_ = null;

			assert( _taskGuard_flags & Flags.done );

			if ( _taskGuard_flags & Flags.error )
				throw new ErrorPoisoningException( );

			// After this context is resumed, the task should be done
			return _taskGuard_data;
		}

		try {
			_taskGuard_data = __traits( getMember, this, _taskGuard_obtainFunctionName )( );
		}
		catch ( Throwable exc ) {
			// Mark this task as erroreous
			const ubyte data = atomicFetchThenOr( _taskGuard_flags, Flags.done | Flags.error );

			// If there were tasks waiting for this guard, issue them (they should be poisoned)
			if ( data & Flags.dependentTasksWaiting )
				__taskGuard_issueWaitingTasks( );

			throw exc;
		}

		assert( _taskGuard_flags & Flags.workInProgress && !( _taskGuard_flags & Flags.done ) );

		// Finish
		const ubyte endData = atomicFetchThenOr( _taskGuard_flags, Flags.done );

		// If there were tasks waiting for this guard, issue them
		if ( endData & Flags.dependentTasksWaiting )
			__taskGuard_issueWaitingTasks( );

		return _taskGuard_data;
	}

	mixin( "alias " ~ identifier ~ " = _taskGuard_func;" );

private:
	pragma( inline ) @property TaskGuardId _taskGuard_id( ) {
		return &_taskGuard_flags;
	}

	void __taskGuard_issueWaitingTasks( ) {
		import beast.utility.atomic : atomicFetchThenOr;
		import beast.work.guard : taskGuardDependentsList, taskGuardResolvingMutex;

		synchronized ( taskGuardResolvingMutex ) {
			assert( _taskGuard_id in taskGuardDependentsList );

			foreach ( task; taskGuardDependentsList[ _taskGuard_id ] )
				context.workManager.issueTask( task );

			taskGuardDependentsList.remove( _taskGuard_id );
		}
	}

}

enum TaskGuardFlags : ubyte {
	done = 1 << 0,
	workInProgress = 1 << 1,
	dependentTasksWaiting = 1 << 2,
	contextSet = 1 << 3,
	error = 1 << 4
}

static __gshared Mutex taskGuardResolvingMutex;

/// Map of contexts that are waiting for a given task guard
static __gshared TaskContext[ ][ TaskGuardId ] taskGuardDependentsList;

enum _init = HookAppInit.hook!( { //
		taskGuardResolvingMutex = new Mutex; //
	} );

final class ErrorPoisoningException : Exception {

public:
	this( ) {
		super( "Error poisoning" );
	}

}
