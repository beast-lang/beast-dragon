module beast.util.util;

import beast.util.identifiable;
import beast.core.error.error;

/// Return expression identificationString value or "#error#" if expression executing results in an error
pragma( inline ) string tryGetIdentificationString( T )( lazy T obj ) {
	if ( obj is null )
		return "#error#";

	try {
		return obj.identificationString;
	}
	catch ( BeastErrorException ) {
		return "#error#";
	}
}
