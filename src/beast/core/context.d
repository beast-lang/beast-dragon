module beast.core.context;

import beast.core.project.project;
import beast.core.task.taskmgr;
import beast.code.lex.lexer;
import beast.code.memory.block;
import beast.core.task.context;
import beast.core.error.guard;
import beast.core.task.worker;
import beast.code.entity.scope_.scope_;
import std.container.rbtree;
import beast.code.memory.ptr : MemoryPtr;
import beast.util.uidgen;
import beast.code.memory.memorymgr;
import std.typecons : Typedef;

/// General project-related data
__gshared Project project;

/// TaskManager is in charge of parallelism and work planning
__gshared TaskManager taskManager;

final class ContextData {

public:
	alias ChangedMemoryBlocks = Typedef!(MemoryBlock[]);
	alias NewMemoryBlocks = Typedef!(MemoryBlock[]);
	alias JobId = UIDGenerator.I;

public:
	pragma(inline) auto session() {
		return sessionData ? sessionData.id : 0;
	}

	pragma(inline) auto subSession() {
		return subSessionStack.length ? subSessionStack[$ - 1] : 0;
	}

public:
	/// Currently working lexer
	Lexer lexer;

public:
	/// Id of the current job (task)
	JobId jobId;

	SessionData sessionData;
	SessionData[] sessionDataStack;

	/// Stack of subsession IDs
	/// Subsessions are to protect memory, same as sessions, but memory is not GC'd on subsession end (it is only on session end)
	UIDGenerator.I[] subSessionStack;

	/// Stores if the current envirovnment is ctime
	/// This is used for different semantic tree build behavior for ctime and non-ctime build (can be necessary sometimes)
	bool isCtime = false;

public:
	/// This is to prevent passing scopes aroung all the time
	DataScope currentScope;

	DataScope[] scopeStack;

public:
	/// Jobs that are about to be issued as soon as the context finishes its current job (or current taskGuard)
	TaskContext.Job[] delayedIssuedJobs;

	TaskContext.Job[][] delayedIssuedJobsStack;

public:
	/// This number is increased with every compile-time function call and decreased by every return
	size_t currentRecursionLevel;

public:
	/// TaskContext of the current running task
	TaskContext taskContext;
	ErrorGuardData errorGuardData;

	/// Error messages are not printed if > 0
	size_t preventErrorPrint;

public:
	final static class SessionData {

	public:
		this(UIDGenerator.I id, SessionPolicy policy) {
			this.id = id;
			this.policy = policy;

			pointers = new RedBlackTree!MemoryPtr;

			// If it is the context policy to watch compile time variable changes, we create it a dedicated container (this applies for function bodies)
			if (policy == SessionPolicy.watchCtChanges) {
				changedMemoryBlocks = new ChangedMemoryBlocks();
				newMemoryBlocks = new NewMemoryBlocks();

			}
			// If the policy is to inherit, we inherit the watch container from parent session (this applies for local scopes)
			else if (policy == SessionPolicy.inheritCtChangesWatcher) {
				assert(context.sessionData);
				changedMemoryBlocks = context.sessionData.changedMemoryBlocks;
				newMemoryBlocks = context.sessionData.newMemoryBlocks;
			}
			// Otherwise, the container is null -> saves are not changes (applies to static variables)
		}

	public:
		/// Sessions separate code executing into logical units. It is not possible to write to memory of other sessions.
		/// Do not edit yourself, call memoryManager.startSession() and memoryManager.endSession()
		UIDGenerator.I id;

		/// Subsessions are to protect memory block as sessions, but:
		/// - Subsessions do not run garbage collection on end
		/// - Parent subsessions can edit child subsession data (parent.subsessionId < child.subsessionId)
		UIDGenerator.I subSessionIDGen;

		/// List of all memory blocks allocated in the current session (mapped by src ptr)
		MemoryBlock[size_t] memoryBlocks;

		/// Pointers created in the current session
		RedBlackTree!MemoryPtr pointers;

		SessionPolicy policy;

		/// Memory blocks whose data has changed (freed/malloced/writtento) since the last check
		/// If null then don't track changes
		ChangedMemoryBlocks* changedMemoryBlocks;
		NewMemoryBlocks* newMemoryBlocks;

	}

}

ContextData context;
