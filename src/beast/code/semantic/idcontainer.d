module beast.code.semantic.idcontainer;

import beast.code.lex.identifier;
import beast.code.semantic.overloadset;
import beast.util.identifiable;
import beast.code.semantic.matchlevel;
import beast.core.error.error;
import std.format : format;

interface IDContainer : Identifiable {

public:
	Overloadset tryResolveIdentifier(Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch);
	Overloadset tryRecursivelyResolveIdentifier(Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch);

public:
	/// Resolves the identifier, throws an error if the overloadset is empty
	final Overloadset expectResolveIdentifier(Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch) {
		auto result = tryResolveIdentifier(id, matchLevel);
		benforce(!result.isEmpty, E.unknownIdentifier, "Could not resolve identifier '%s' for %s".format(id.str, identificationString));
		return result;
	}

}
