module beast.core.context;

import beast.core.project.project;
import beast.core.task.taskmgr;
import beast.code.lex.lexer;
import beast.code.memory.block;
import beast.core.task.context;
import beast.core.error.guard;
import beast.core.task.worker;
import beast.code.data.scope_.scope_;

/// General project-related data
__gshared Project project;

/// TaskManager is in charge of parallelism and work planning
__gshared TaskManager taskManager;

struct ContextData {

	public:
		/// Currently working lexer
		Lexer lexer;

	public:
		/// Id of the current job (task)
		size_t jobId;

		/// Sessions separate code executing into logical units. It is not possible to write to memory of other sessions.
		/// Do not edit yourself, call memoryManager.startSession() and memoryManager.endSession()
		size_t session;

		/// Sessions can be nested (they're absolutely independent though); last session in the stack is saved in the session variable for speed up
		size_t[ ] sessionStack;

		/// List of all memory blocks allocated in the current session
		MemoryBlock[ ] sessionMemoryBlocks;

		/// Memory blocks allocated by the sessions in the stack
		MemoryBlock[ ][ ] sessionMemoryBlockStack;

		/// This is to prevent passing scopes aroung all the time
		DataScope currentScope;

		DataScope[] scopeStack;

	public:
		/// TaskContext of the current running task
		TaskContext taskContext;
		ErrorGuardData errorGuardData;

}

/// Context-local (fiber-local) pointer to working context
ContextData context;
