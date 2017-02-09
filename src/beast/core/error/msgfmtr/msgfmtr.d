module beast.core.error.msgfmtr.msgfmtr;

public {
	import beast.core.error.msgfmtr.gnu;
	import beast.core.error.msgfmtr.json;
}

import beast.toolkit;
import beast.core.project.configuration;
import beast.core.error.errormsg;

MessageFormatter function( )[ ProjectConfiguration.MessageFormat ] messageFormatterFactory;

abstract class MessageFormatter {

public:
	abstract string formatErrorMessage( ErrorMessage msg );

}

private alias _init = HookAppInit.hook!( {
	messageFormatterFactory = [  //
	ProjectConfiguration.MessageFormat.gnu : { return cast( MessageFormatter ) new MessageFormatter_GNU; }, //
		ProjectConfiguration.MessageFormat.json : { return cast( MessageFormatter ) new MessageFormatter_JSON; } //
		 ];
} );
