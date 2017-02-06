module beast.core.context;

import beast.toolkit;
import beast.code.lex.lexer;
import beast.core.project;
import beast.core.task.context;
import beast.core.task.manager;

/// Project is a global instance
__gshared Project project;

/// Work manager is also a global instance
__gshared TaskManager taskManager;

struct ContextData {

public:
	/// Currently working lexer
	Lexer lexer;
	TaskContext taskContext;
	ErrorGuardData errorGuardData;

}

/// Context-local (fiber-local) pointer to working context
ContextData context;
