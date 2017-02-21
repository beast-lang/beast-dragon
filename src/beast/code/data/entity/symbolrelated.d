module beast.code.data.entity.symnolrelated;

import beast.code.data.toolkit;

abstract class SymbolRelatedDataEntity : DataEntity {

public:
	this( DataScope scope_, Symbol symbol ) {
		super( scope_ );
		symbol_ = symbol;
	}

public:
	final override Identifier identifier( ) {
		return symbol_.identifier;
	}

	final override string identificationString( ) {
		return symbol_.identificationString;
	}

	final override AST_Node ast( ) {
		return symbol_.ast;
	}

private:
	Symbol symbol_;

}
