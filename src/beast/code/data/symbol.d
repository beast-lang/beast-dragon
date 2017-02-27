module beast.code.data.symbol;

import beast.code.data.toolkit;
import beast.code.data.entitycontainer.container;

/// Declaration of something (not really explaining, I know)
/// Symbols are only on the module level declarations (and class etc) - local variables are not symbols, they're just DataEntities

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

	/// Namespace/scope this declaration is related to (it doesn't have to belong there actually)
	final EntityContainer parent( ) {
		return parent_;
	}
	void parent( EntityContainer set ) {
		parent_ = set;
	}

	/// AST node related to the declaration; can be null
	AST_Node ast( ) {
		return null;
	}

	/// Location of where in the code the symbol was declared (or code that +- matches it)
	final CodeLocation codeLocation( ) {
		return ast ? ast.codeLocation : cast( CodeLocation ) null;
	}

public:
	/// Creates and returns a data entity representing access to this declaration via given instance
	abstract DataEntity data( DataEntity parentInstance = null );

public:
	string identification( ) {
		return identifier ? identifier.str : "(???)";
	}

	override string identificationString( ) {
		string result;

		if ( parent_ )
			result = parent_.identificationString;

		if ( result )
			result ~= ".";

		result ~= identification;

		return result;
	}

private:
	EntityContainer parent_;

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

	final override string identificationString( ) {
		return symbol_.identificationString;
	}

	final override AST_Node ast( ) {
		return symbol_.ast;
	}

private:
	Symbol symbol_;

}
