module beast.toolkit;

public {
	import beast.code.lex.identifier : Identifier;
	import beast.code.lex.token : Token;
	import beast.core.context : context;
	import beast.core.error.error : berror, benforce, breport, E;
	import beast.core.project.codelocation : CodeLocation;
	import beast.core.task.guard : TaskGuard;
	import beast.util.identifiable : Identifiable;
	import std.algorithm;
	import std.array;
	import std.conv : to;
	import std.range : map;
	import std.string;
	import std.typecons : Rebindable;
}

import beast.util.hooks;

alias HookAppInit = Hook!"appInit";
