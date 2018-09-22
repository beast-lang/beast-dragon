module beast.code.semantic.namespace.namespace;

import beast.code.lex.identifier;
import beast.code.semantic.overloadset;
import beast.code.semantic.entity;
import beast.core.error.error;
import beast.util.identifiable;
import std.format : format;

abstract class Namespace : Identifiable {

public:
	this(Namespace parent) {
		parent_ = parent;
	}

public:
	pragma(inline) final @property Namespace parent() const {
		return parent_;
	}

public:
	string identification() {
		return null;
	}

	string identificationString() {
		if (!parent)
			return identification;

		string result = parent.identificationString;
		string identification = identification;
		if (identification && result)
			result ~= ".";

		result ~= identification;
		return result;
	}

public:
	Overloadset tryResolveIdentifier(Identifier id, SemanticNode context) {
		if (context is null)
			return overloadsets_.get(id, Overloadset());
		else
			return overloadsets_.get(id, Overloadset()).map!(x => SemanticEntity(x.node, context, x.matchLevel)).array.Overloadset;
	}

	Overloadset tryRecursivelyResolveIdentifier(Identifier id, SemanticNode context) {
		if (auto result = tryResolveIdentifier(id))
			return result;

		if (parent_)
			return parent_.tryRecursivelyResolveIdentifier(id, context);

		return Overloadset();
	}

public:
	/// Resolves the identifier, throws an error if the overloadset is empty
	pragma(inline) final Overloadset expectResolveIdentifier(Identifier id) {
		if (auto result = tryResolveIdentifier(id))
			return result;

		berror(!result.isEmpty, E.unknownIdentifier, "Could not resolve identifier '%s' for %s".format(id.str, identificationString));
	}

protected:
	void addSymbol(Symbol s) {
		members_ ~= s;

		if (auto id = s.identifier)
			overloadsets_.require(id, []) ~= s;
	}

	void addSymbols(Symbol[] ss) {
		members_ ~= ss;

		foreach (Symbol s; ss) {
			if (auto id = s.identifier)
				overloadsets_.require(id, []) ~= s;
		}
	}

protected:
	/// Parent namespace, can be null
	Namespace parent_;

	/// List of all members of the namespace. 
	SemanticEntity[] members_;

	/// List of members of the namespace that have identifier, grouped by the identifier.
	Overloadset[Identifier] overloadsets_;

}
