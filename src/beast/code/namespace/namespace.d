module beast.code.namespace.namespace;

import beast.code.entity.dataentity;
import beast.code.entity.matchlevel;
import beast.code.lex.identifier;
import beast.code.symbol.symbol;

abstract class Namespace {

public:
	abstract Symbol[] resolveIdentifier(Identifier identifier);

}