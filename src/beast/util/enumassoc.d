module beast.util.enumassoc;

/// Returns associative array identifier => enum
template enumAssoc(Enum) if (is(Enum == enum)) {
	static immutable Enum[string] enumAssoc;

	shared static this() {
		Enum[string] result;

		foreach (key; __traits(derivedMembers, Enum))
			result[key] = __traits(getMember, Enum, key);

		enumAssoc = cast(immutable) result;
	}
}

/// Returns associative array enum => identifier
template enumAssocInvert(Enum, string[Enum] customVals = null) if (is(Enum == enum)) {
	static immutable string[Enum] enumAssocInvert;

	shared static this() {
		string[Enum] result;

		foreach (memberName; __traits(derivedMembers, Enum)) {
			enum member = __traits(getMember, Enum, memberName);

			if (auto mem = member in customVals)
				result[member] = *mem;
			else
				result[member] = memberName;
		}

		enumAssocInvert = cast(immutable) result;
	}
}
