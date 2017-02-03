module beast.toolkit;

public {
	import beast.code.lex.identifier;
	import beast.code.lex.token;
	import beast.core.context;
	import beast.core.error;
	import beast.core.project.codelocation;
	import beast.core.task.guard;
	import beast.utility.identifiable;
	import std.algorithm;
	import std.array;
	import std.conv : to;
	import std.range.interfaces;
	import std.range;
	import std.string;
	import std.typecons : Rebindable;
}

import beast.utility.hooks;

alias HookAppInit = Hook!"appInit";
