module beast.util.util;

import beast.util.identifiable;
import beast.core.error.error;
import beast.core.context;

/// Return expression identificationString value or "#error#" if expression executing results in an error
pragma(inline) string tryGetIdentificationString(T)(lazy T obj) {
	context.preventErrorPrint++;
	scope (exit)
		context.preventErrorPrint--;

	try {
		auto data = obj();

		if (data is null)
			return "#error#";

		return data.identificationString;
	}
	catch (BeastErrorException) {
		return "#error#";
	}
}

/// Return expression identification value or "#error#" if expression executing results in an error
pragma(inline) string tryGetIdentification(T)(lazy T obj) {
	context.preventErrorPrint++;
	scope (exit)
		context.preventErrorPrint--;

	try {
		auto data = obj();

		if (data is null)
			return "#error#";

		return data.identification;
	}
	catch (BeastErrorException) {
		return "#error#";
	}
}
