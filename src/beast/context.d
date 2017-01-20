module beast.context;

import beast.lex.lexer;
import beast.project.project;
import beast.work.context;
import beast.work.manager;

struct ContextData {

public:
	/// Project is a global instance
	static __gshared Project project;

	/// Work manager is also a global instance
	static __gshared WorkManager workManager;

	/// Currently working lexer
	Lexer lexer;

	TaskContext taskContext;

public:
	shared static this( ) {
		project = new Project;
		workManager = new WorkManager;
	}

}

/// Context-local (fiber-local) pointer to working context
ContextData context;
