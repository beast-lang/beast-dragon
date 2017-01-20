module beast.toolkit;

public {
	import std.conv: to;

	import beast.error;
	import beast.context;
	import beast.project.project;
	import beast.task.guard;
}

import beast.utility.hooks;

alias HookAppStart = Hook!"appStart";
alias HookAppInit = Hook!"appInit";
alias HookAppUninit = Hook!"appUninit";