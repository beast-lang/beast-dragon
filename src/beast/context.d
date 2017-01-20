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

private:
	enum _init = HookAppStart.hook!({
		project = new Project;
		taskManager = new TaskManager;

		taskManager.spawnWorkers();
	});
	enum _uninit = HookAppUninit.hook!({
		taskManager.quitWorkers();
	});

}

/// Context-local (fiber-local) pointer to working context
ContextData context;
