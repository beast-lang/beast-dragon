module beast.core.error.errormsg;

import beast.toolkit;

final class ErrorMessage {

public:
	string message;
	E error;
	ErrorSeverity severity;
	CodeLocation codeLocation;

}
