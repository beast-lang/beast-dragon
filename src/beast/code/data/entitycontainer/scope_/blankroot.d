module beast.code.data.entitycontainer.scope_.blankroot;

import beast.code.data.toolkit;

/// Root scope = there is no parent at all
class BlankRootDataScope : DataScope {

public:
	final string identificationString( ) {
		return "(root)";
	}

}
