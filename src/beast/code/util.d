module beast.code.util;

import beast.code.toolkit;

/// Translates decoration identifier to decorator identifier ( @<something> => #decorator_<something> )
Identifier decorationIdentifierToDecoratorIdentifier(Identifier id) {
	return Identifier("#decorator_" ~ id.str);
}
