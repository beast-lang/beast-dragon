module beast.code.data.callable.invalidmtch;

import beast.code.data.toolkit;
import beast.code.data.callable.match;

/// When it is certain that the function call has no match from the beginning (for example when calling a member function without a context instance)
final class InvalidCallableMatch : CallableMatch {

	public:
		this( DataEntity sourceDataEntity, string errorStr ) {
			super( sourceDataEntity );

			this.errorStr = errorStr;
		}

	protected:
		final override MatchLevel _finish( ) {
			return MatchLevel.noMatch;
		}

}