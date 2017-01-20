module beast.context;

import beast.toolkit;
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

private:
	enum _init = HookAppStart.hook!({
		project = new Project;
		workManager = new WorkManager;

		workManager.spawnWorkers();
	});
	enum _uninit = HookAppUninit.hook!({
		workManager.quitWorkers();
	});

}

/// Context-local (fiber-local) pointer to working context
ContextData context;
