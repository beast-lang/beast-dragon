module beast.core.context;

import beast.toolkit;
import beast.code.lex.lexer;
import beast.core.project.project;
import beast.core.task.context;
import beast.core.task.manager;

struct ContextData {

public:
	/// Project is a global instance
	static __gshared Project project;

	/// Work manager is also a global instance
	static __gshared TaskManager taskManager;

	/// Currently working lexer
	Lexer lexer;

	TaskContext taskContext;
	ErrorGuardData errorGuardData;

}

/// Context-local (fiber-local) pointer to working context
ContextData context;
