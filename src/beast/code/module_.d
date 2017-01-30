module beast.code.module_;

import beast.toolkit;
import beast.project.codesource;
import beast.code.ast.module_;
import beast.code.lex.lexer;
import std.regex;

/// Abstraction of module in Beast
final class Module : CodeSource, Identifiable {
	mixin TaskGuard!( "ast", AST_Module );

public:
	this( CTOR_FromFile _, string filename, ExtendedIdentifier identifier ) {
		this.identifier = identifier;

		super( _, filename );
	}

public:
	const ExtendedIdentifier identifier;
	alias ast = _ast;

public:
	override @property string identificationString( ) const {
		return identifier.str;
	}

private:
	AST_Module obtain_ast( ) {
		assert( !context.lexer );
		context.lexer = new Lexer( this );
		context.lexer.getNextToken();

		auto result = AST_Module.parse( );

		context.lexer = null;
		benforce( result.identifier == this.identifier, E.moduleNameMismatch, "Module '" ~ result.identifier.str ~ "' should be named '" ~ this.identifier.str ~ "' (because of directory tree)" );

		return result;
	}

}

bool isValidModuleOrPackageIdentifier( string str ) {
	static auto rx = ctRegex!"^[a-z_][a-z0-9_]*$";
	return cast( bool ) str.matchFirst( rx );
}
