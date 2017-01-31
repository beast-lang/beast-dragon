module beast.code.module_;

import beast.toolkit;
import beast.core.project.codesource;
import beast.code.lex.lexer;
import std.regex;
import beast.code.symbol.module_;
import beast.code.ast.module_;

/// Abstraction of module in Beast (from project point of view)
final class Module : CodeSource, Identifiable {
	mixin TaskGuard!( "symbol", Symbol_Module );

public:
	this( CTOR_FromFile _, string filename, ExtendedIdentifier identifier ) {
		this.identifier = identifier;

		super( _, filename );
	}

public:
	const ExtendedIdentifier identifier;
	alias symbol = _symbol;

public:
	override @property string identificationString( ) const {
		return identifier.str;
	}

private:
	Symbol_Module obtain_symbol( ) {
		assert( !context.lexer );

		context.lexer = new Lexer( this );
		context.lexer.getNextToken( );

		auto ast = AST_Module.parse( );

		context.lexer = null;
		benforce( ast.identifier == this.identifier, E.moduleNameMismatch, "Module '" ~ ast.identifier.str ~ "' should be named '" ~this.identifier.str ~ "'", CodeLocation( this ).errGuardFunction );

		return new Symbol_Module( this, ast );
	}

}

bool isValidModuleOrPackageIdentifier( string str ) {
	static auto rx = ctRegex!"^[a-z_][a-z0-9_]*$";
	return cast( bool ) str.matchFirst( rx );
}
