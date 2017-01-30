module beast.context;

import beast.toolkit;
import beast.lex.lexer;
import beast.project.project;
import beast.task.context;
import beast.task.manager;

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
