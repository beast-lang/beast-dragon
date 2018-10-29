module beast.code.entity.codenamespace.namespace;

import beast.code.entity.toolkit;
import beast.util.identifiable;
import std.array;

abstract class Namespace : Identifiable {

public:
	this(Identifiable parent) {
		parent_ = parent;
	}

public:
	Symbol[] members() {
		debug assert(initialized_);

		return members_;
	}

	/// If there are any symbols in this namespace with given identifier, returns them in an overloadset.
	Overloadset resolveIdentifier(Identifier id, DataEntity instance, MatchLevel matchLevel = MatchLevel.fullMatch) {
		debug assert(initialized_);

		auto data = id in groupedMembers_;
		if (!data)
			return Overloadset();

		Overloadset result;
		Overloadset.Appender sink = appender(&result.data);

		foreach (Symbol s; *data)
			s.overloadset(sink, matchLevel, instance);

		return result;
	}

public:
	final override string identificationString() {
		return parent_.identificationString;
	}

protected:
	final void initialize_(Symbol[] symbolList) {
		debug assert(!initialized_);

		members_ = symbolList;

		// Construct overloadset
		foreach (sym; symbolList) {
			assert(sym.identifier);

			if (auto ptr = sym.identifier in groupedMembers_)
				*ptr ~= sym;
			else
				groupedMembers_[sym.identifier] = [sym];
		}

		debug initialized_ = true;
	}

private:
	Identifiable parent_;
	Symbol[] members_;
	Symbol[][Identifier] groupedMembers_;
	debug bool initialized_;

}
