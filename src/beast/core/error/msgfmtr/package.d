module beast.core.error.msgfmtr;

public {
	import beast.core.error.msgfmtr.gnu;
	import beast.core.error.msgfmtr.json;
}

import beast.core.project.configuration;
import beast.core.error.errormsg;

immutable MessageFormatter function( )[ ProjectConfiguration.MessageFormat ] messageFormatterFactory;
shared static this( ) {
	messageFormatterFactory = [  //
	ProjectConfiguration.MessageFormat.gnu : { return cast( MessageFormatter ) new MessageFormatter_GNU; }, //
		ProjectConfiguration.MessageFormat.json : { return cast( MessageFormatter ) new MessageFormatter_JSON; } //
		 ];
}

abstract class MessageFormatter {

public:
	abstract string formatErrorMessage( ErrorMessage msg );

}
