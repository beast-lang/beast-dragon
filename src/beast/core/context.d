module beast.core.context;

import beast.toolkit;
import beast.code.lex.lexer;
import beast.core.project.project;
import beast.core.task.context;
import beast.core.task.manager;
import beast.code.memory.mgr;
import beast.code.hwenv.hwenv;

/// General project-related data
__gshared Project project;

/// TaskManager is in charge of parallelism and work planning
__gshared TaskManager taskManager;

struct ContextData {

public:
	/// Currently working lexer
	Lexer lexer;

public:
	/// Sessions separate code executing into logical units. It is not possible to write to memory of other sessions.
	/// Do not edit yourself, call memoryManager.startSession() and memoryManager.endSession()
	size_t session;

	/// Sessions can be nested (they're absolutely independent though); last session in the stack is saved in the session variable for speed up
	size_t[ ] sessionStack;

public:
	/// TaskContext of the current running task
	TaskContext taskContext;
	ErrorGuardData errorGuardData;

}

/// Context-local (fiber-local) pointer to working context
ContextData context;
