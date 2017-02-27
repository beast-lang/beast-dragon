module beast.code.data.symbol;

import beast.code.data.toolkit;

/// Declaration of something (not really explaining, I know)
abstract class Symbol : Identifiable {

public:
	enum DeclType {
		staticVariable,
		memberVariable,
		staticFunction,
		memberFunction,
		staticClass,
		memberClass,
		enum_, // enum is always static
		decorator,
		module_
	}

public:
	/// Identifier of the declaration; can be null
	abstract Identifier identifier( );

	/// Type of the declaration
	abstract DeclType declarationType( );

	/// AST node related to the declaration; can be null
	AST_Node ast( ) {
		return null;
	}

	/// Location of where in the code the symbol was declared (or code that +- matches it)
	final CodeLocation codeLocation( ) {
		return ast ? ast.codeLocation : cast( CodeLocation ) null;
	}

public:
	/// Data entity representing the symbol, either with static static access or via instance of parent type
	abstract DataEntity dataEntity( DataEntity parentInstance = null );

public:
	override string identificationString( ) {
		return dataEntity.identificationString;
	}

}

abstract class SymbolRelatedDataEntity : DataEntity {

public:
	this( Symbol symbol ) {
		symbol_ = symbol;
	}

public:
	final override Identifier identifier( ) {
		return symbol_.identifier;
	}

	final override AST_Node ast( ) {
		return symbol_.ast;
	}

private:
	Symbol symbol_;

}
