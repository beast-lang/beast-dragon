module beast.code.data.scope_.blankroot;

import beast.code.data.toolkit;

/// Root scope = there is no parent at all
class BlankRootDataScope : DataScope {

public:
	final string identificationString( ) {
		return "(root)";
	}

public:
	override ref size_t currentBasePointerOffset( ) {
		return currentBasePointerOffset_;
	}

private:
	size_t currentBasePointerOffset_;

}
