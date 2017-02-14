module beast.code.sym.symbol;

import beast.code.sym.toolkit;

/// Base class for all symbols
abstract class Symbol : Identifiable {

public:
	enum BaseType {
		decorator,
		variable,
		module_
	}

public:
	Symbol parent;

public:
  abstract @property BaseType baseType();

	/// Identifier of the symbol, may be null (for template instances, anonymous functions etc.)
	@property Identifier identifier( ) {
		return null;
	}

	/// For template instances, the base name is the template identifier; otherwise it is equal to identifier
	@property Identifier baseName( ) {
		return identifier;
	}

public:
	override @property string identificationString( ) {
		string result;
		if( parent )
			result ~= parent.identificationString;

		if( baseName )
			result ~= ( result.length ? "." : null ) ~ baseName.str;

		return result;
	}

public:
	/// AST node related to the symbol (declaration)
	@property AST_Node ast( ) {
		return null;
	}

	/// Location of where in the code the symbol was declared (or code that +- matches it)
	@property CodeLocation codeLocation( ) {
		return ast ? ast.codeLocation : cast( CodeLocation ) null;
	}

public:
	/// Resolves identifier. This function only looks into current symbol namespace
	Overloadset resolveIdentifier( Identifier id ) {
		return Overloadset( );
	}

	/// Recursively resolves identifier - if it doesn't found any overloads in the current symbol namespace, looks into parent symbol namespace, etc.
	/// This function can be overloaded - this is used for making some symbols accessible only from "inside" of the scope
	Overloadset resolveIdentifierRecursively( Identifier id ) {
		// First try looking in the current scope
		if ( Overloadset result = resolveIdentifier( id ) )
			return result;

		// If not found, recursively look in parent ones
		if ( parent )
			return parent.resolveIdentifierRecursively( id );

		return Overloadset( );
	}

}
