module beast.error.msgfmtr.msgfmtr;

import beast.error.errormsg;

abstract class MessageFormatter {
	
public:
	abstract string formatErrorMessage( ErrorMessage msg );

}