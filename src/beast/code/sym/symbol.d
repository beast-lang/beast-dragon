module beast.code.sym.symbol;

import beast.code.toolkit;

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
	abstract @property Identifier identifier( );

	/// Type of the declaration
	abstract @property DeclType declarationType( );

	/// Namespace this declaration is related to (it doesn't have to belong there actually)
	abstract @property Namespace parentNamespace( );

	/// AST node related to the declaration; can be null
	@property AST_Node ast( ) {
		return null;
	}

	/// Location of where in the code the symbol was declared (or code that +- matches it)
	final @property CodeLocation codeLocation( ) {
		return ast ? ast.codeLocation : cast( CodeLocation ) null;
	}

public:
	/// Creates and returns a data entity representing access to this declaration via given instance
	abstract DataEntity data( DataEntity parentInstance );

public:
	override string identificationString( ) {
		string result;

		if ( auto parent = parentNamespace )
			result = parent.identificationString;

		if ( result )
			result ~= ".";

		if ( auto id = identifier )
			result ~= id.str;
		else
			result ~= "(declaration)";

		return result;
	}

}
