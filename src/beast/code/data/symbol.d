module beast.code.data.symbol;

import beast.code.data.toolkit;

/// Declaration of something (not really explaining, I know)
abstract class Symbol : Identifiable {
	mixin TaskGuard!"outerHashObtaining";

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

	override string identificationString( ) {
		return dataEntity.identificationString;
	}

	/// Location of where in the code the symbol was declared (or code that +- matches it)
	final CodeLocation codeLocation( ) {
		return ast ? ast.codeLocation : cast( CodeLocation ) null;
	}

	/// Outer hash - hash that is generated based on entity declaration and surroundings, not its definition (considering classes, functions, etc)
	final Hash outerHash( ) {
		enforceDone_outerHashObtaining( );
		return outerHash_;
	}

public:
	/// Data entity representing the symbol, either with static static access or via instance of parent type
	abstract DataEntity dataEntity( DataEntity parentInstance = null );

public:
	/// Builds code for declarations/definitions of current symbol and all children symbols
	void buildDefinitionsCode( CodeBuilder cb ) {
		assert( 0, "buildDefinitionsCode not implemented for " ~ identificationString );
	}

protected:
	Hash outerHash_;

protected:
	void execute_outerHashObtaining( ) {
		outerHash_ = identifier.hash;

		if ( auto parent = dataEntity.parent )
			outerHash_ += parent.outerHash;
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

	final override Hash outerHash( ) {
		return symbol_.outerHash;
	}

private:
	Symbol symbol_;

}
