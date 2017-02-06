module beast.core.error.msgfmtr.json;

import beast.core.error.errormsg;
import beast.core.error.msgfmtr;
import beast.toolkit;
import std.json;

final class MessageFormatter_JSON : MessageFormatter {

public:
	this( ) {
		gnuFormatter = new MessageFormatter_GNU;
	}

public:
	override string formatErrorMessage( ErrorMessage msg ) {
		JSONValue[ string ] result;

		result[ "gnuFormat" ] = gnuFormatter.formatErrorMessage( msg );
		result[ "message" ] = msg.message;
		result[ "error" ] = msg.error.to!string;
		result[ "severity" ] = msg.severity.to!string;

		if ( auto cl = msg.codeLocation ) {
			result[ "file" ] = cl.file;

			if ( cl.startLine ) {
				result[ "line" ] = cl.startLine;
				result[ "column" ] = cl.startColumn;
				result[ "pos" ] = cl.startPos;

				result[ "toLine" ] = cl.endLine;
				result[ "toColumn" ] = cl.endColumn;
				result[ "toPos" ] = cl.endPos;
			}
		}

		const JSONValue _result = JSONValue( result );
		return _result.toJSON;
	}

private:
	MessageFormatter_GNU gnuFormatter;

}
