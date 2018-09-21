module beast.code.semantic.callable.invalidmtch;

import beast.code.semantic.toolkit;
import beast.code.semantic.callable.match;

/// When it is certain that the function call has no match from the beginning (for example when calling a member function without a context instance)
final class InvalidCallableMatch : CallableMatch {

public:
	this(DataEntity sourceDataEntity, string errorStr) {
		super(sourceDataEntity);

		this.errorStr = errorStr;
	}

protected:
	final override MatchLevel _finish() {
		return MatchLevel.noMatch;
	}

}
