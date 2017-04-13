module beast.core.context;

import beast.core.project.project;
import beast.core.task.taskmgr;
import beast.code.lex.lexer;
import beast.code.memory.block;
import beast.core.task.context;
import beast.core.error.guard;
import beast.core.task.worker;
import beast.code.data.scope_.scope_;
import std.container.rbtree;
import beast.code.memory.ptr : MemoryPtr;
import beast.util.uidgen;

/// General project-related data
__gshared Project project;

/// TaskManager is in charge of parallelism and work planning
__gshared TaskManager taskManager;

final class ContextData {

	public:
		pragma( inline ) auto session( ) {
			return sessionData.id;
		}

	public:
		/// Currently working lexer
		Lexer lexer;

	public:
		/// Id of the current job (task)
		UIDGenerator.I jobId;

		SessionData sessionData;
		SessionData[ ] sessionDataStack;

	public:
		/// This is to prevent passing scopes aroung all the time
		DataScope currentScope;

		DataScope[ ] scopeStack;

	public:
		/// Jobs that are about to be issued as soon as the context finishes its current job (or current taskGuard)
		TaskContext.Job[ ] delayedIssuedJobs;

		TaskContext.Job[ ][ ] delayedIssuedJobsStack;

	public:
		/// This number is increased with every compile-time function call and decreased by every return
		size_t currentRecursionLevel;

	public:
		/// TaskContext of the current running task
		TaskContext taskContext;
		ErrorGuardData errorGuardData;

	public:
		final static class SessionData {

			public:
				this( UIDGenerator.I id ) {
					this.id = id;
					pointers = new RedBlackTree!MemoryPtr;
				}

			public:
				/// Sessions separate code executing into logical units. It is not possible to write to memory of other sessions.
				/// Do not edit yourself, call memoryManager.startSession() and memoryManager.endSession()
				UIDGenerator.I id;

				/// List of all memory blocks allocated in the current session (mapped by src ptr)
				MemoryBlock[ size_t ] memoryBlocks;

				/// Pointers created in the current session
				RedBlackTree!MemoryPtr pointers;

		}

}

/// Context-local (fiber-local) pointer to working context
ContextData context;
