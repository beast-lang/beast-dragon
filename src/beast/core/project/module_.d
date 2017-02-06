module beast.core.project.module_;

import beast.code.ast.decl.module_;
import beast.code.lex.lexer;
import beast.code.symbol.module_.usermodule;
import beast.core.project.codesource;
import beast.core.project.configuration;
import beast.toolkit;
import std.regex;

/// Abstraction of module in Beast (as a project file)
/// See also Symbol_Module and Symbol_UserModule in beast.code.symbol.module_.XX
final class Module : CodeSource, Identifiable {
	mixin TaskGuard!( "parsedData" );

public:
	this( CTOR_FromFile _, string filename, ExtendedIdentifier identifier ) {
		this.identifier = identifier;

		super( _, filename );
	}

public:
	ExtendedIdentifier identifier;

	@property AST_Module ast( ) {
		enforce_parsedData( );
		return ast_;
	}

	/// Symbol of the module
	@property Symbol_UserModule symbol( ) {
		enforce_parsedData( );
		return symbol_;
	}

	@property Token[ ] tokenList( ) {
		// TODO: Don't always keep tokenlist
		enforce_parsedData( );
		return tokenList_;
	}

public:
	override @property string identificationString( ) {
		return identifier.str;
	}

private:
	void obtain_parsedData( ) {
		assert( !context.lexer );

		Lexer lexer = new Lexer( this );
		context.lexer = lexer;
		scope ( exit )
			context.lexer = null;

		// If we are instructed to do only lexing phase, do it
		if ( project.configuration.stopOnPhase == ProjectConfiguration.StopOnPhase.lexing ) {
			while ( lexer.getNextToken != Token.Special.eof ) {
			}

			tokenList_ = lexer.generatedTokens;
			return;
		}

		// Read first token
		lexer.getNextToken( );

		ast_ = AST_Module.parse( );
		benforce( ast_.identifier == identifier, E.moduleNameMismatch, "Module '" ~ ast_.identifier.str ~ "' should be named '" ~ identifier.str ~ "'", CodeLocation( this ).errGuardFunction );

		tokenList_ = lexer.generatedTokens;

		if ( project.configuration.stopOnPhase == ProjectConfiguration.StopOnPhase.parsing )
			return;

		symbol_ = new Symbol_UserModule( this, ast_ );
	}

private:
	AST_Module ast_;
	Symbol_UserModule symbol_;
	Token[ ] tokenList_;

}

bool isValidModuleOrPackageIdentifier( string str ) {
	static auto rx = ctRegex!"^[a-z_][a-z0-9_]*$";
	return cast( bool ) str.matchFirst( rx );
}
