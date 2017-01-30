module beast.error.msgfmtr;

public {
	import beast.error.msgfmtr.msgfmtr;
	import beast.error.msgfmtr.gnu;
	import beast.error.msgfmtr.json;
}

import beast.project.configuration;

enum messageFormatterFactory = [  //
	ProjectConfiguration.MessageFormat.gnu : { return cast( MessageFormatter ) new MessageFormatter_GNU; }, //
	ProjectConfiguration.MessageFormat.json : { return cast( MessageFormatter ) new MessageFormatter_JSON; } //
	 ];
