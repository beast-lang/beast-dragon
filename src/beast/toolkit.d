module beast.toolkit;

public {
	import std.conv : to;
	import std.typecons : Rebindable;

	import beast.core.context;
	import beast.core.error;
	import beast.code.lex.identifier;
	import beast.code.lex.token;
	import beast.core.project.codelocation;
	import beast.core.task.guard;
	import beast.utility.identifiable;
}

import beast.utility.hooks;

alias HookAppInit = Hook!"appInit";
