module beast.code.sym.symbol;

import beast.code.toolkit;

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

	/// Namespace this declaration is related to (it doesn't have to belong there actually)
	abstract Namespace parentNamespace( );

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

		if ( auto parent = parentNamespace )
			result = parent.identificationString;

		if ( result )
			result ~= ".";

		result ~= identification;

		return result;
	}

}
