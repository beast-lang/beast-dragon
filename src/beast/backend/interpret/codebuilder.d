module beast.backend.interpret.codebuilder;

import beast.backend.toolkit;

/// "CodeBuilder" that builds code for the internal interpret
final class CodeBuilder_Interpret : CodeBuilder {

	public:
		final string identificationString( ) {
			return "interpret";
		}

}
