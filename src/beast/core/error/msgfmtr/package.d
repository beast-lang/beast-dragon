module beast.core.error.msgfmtr;

public {
	import beast.core.error.msgfmtr.msgfmtr;
	import beast.core.error.msgfmtr.gnu;
	import beast.core.error.msgfmtr.json;
}

import beast.core.project.configuration;

enum messageFormatterFactory = [  //
	ProjectConfiguration.MessageFormat.gnu : { return cast( MessageFormatter ) new MessageFormatter_GNU; }, //
	ProjectConfiguration.MessageFormat.json : { return cast( MessageFormatter ) new MessageFormatter_JSON; } //
	 ];
