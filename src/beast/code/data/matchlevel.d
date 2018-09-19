module beast.code.data.matchlevel;

enum MatchLevel : uint {
	fullMatch = 0, /// All types match
	implicitCastsNeeded = 1, /// At least one implicit cast was needed
	inferrationsNeeded = implicitCastsNeeded << 1, /// At least one inferration was needed
	baseClass = inferrationsNeeded << 1, /// Got the overload from base class
	alias_ = baseClass << 1, /// Overload is accessed through alias
	staticCall = alias_ << 1, /// Called static function via an object instance
	compilerDefined = staticCall << 1, /// Item is compiler defined
	fallback = compilerDefined << 1, /// Function is fallback (is used only when no non-fallback function is possible)
	noMatch = cast(ubyte)-1, /// Function does not match the arguments at all
}
