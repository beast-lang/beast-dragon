module beast.core.error.errormsg;

import beast.toolkit;
import beast.core.project.codelocation;

final class ErrorMessage {

	public:
		string message;
		E error;
		ErrorSeverity severity;
		CodeLocation codeLocation;

}
