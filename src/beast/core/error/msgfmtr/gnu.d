module beast.core.error.msgfmtr.gnu;

import beast.core.error.errormsg;
import beast.core.error.msgfmtr.msgfmtr;
import beast.toolkit;
import std.conv;

final class MessageFormatter_GNU : MessageFormatter {

public:
	override string formatErrorMessage( ErrorMessage msg ) {
		string result;

		if ( auto cl = msg.codeLocation ) {
			result ~= cl.file ~ ":";

			if ( cl.startLine ) {
				result ~= cl.startLine.to!string ~ "." ~ cl.startColumn.to!string;
				if ( cl.endLine != cl.startLine )
					result ~= "-%s.%s".format( cl.endLine.to!string, cl.endColumn.to!string );
				else
					result ~= "-" ~ cl.endColumn.to!string;

				result ~= ":";

				/*if ( cl.endPos - cl.startPos < 80 )
					result ~= " '%s':".format( cl.source.content[ cl.startPos .. cl.endPos ].replace( "\n", "\\n" ) );*/
			}

		}
		else
			result = "beast:";

		result ~= " %s %s: %s".format( ErrorSeverityStrings[ msg.severity ], msg.error.to!string, msg.message );

		return result;
	}

}
