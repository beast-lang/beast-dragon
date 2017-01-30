module beast.core.error.msgfmtr.msgfmtr;

import beast.core.error.errormsg;

abstract class MessageFormatter {
	
public:
	abstract string formatErrorMessage( ErrorMessage msg );

}