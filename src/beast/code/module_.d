module beast.code.module_;

import beast.code.ast.decl.module_;
import beast.code.lex.lexer;
import beast.code.symbol.module_.usermodule;
import beast.core.project.codesource;
import beast.core.project.configuration;
import beast.toolkit;
import std.regex;

/// Abstraction of module in Beast (from project point of view)
final class Module : CodeSource, Identifiable {
	mixin TaskGuard!( "parsingData", ParsingData );

public:
	struct ParsingData {
		AST_Module ast;
		Symbol_UserModule symbol;
		Token[ ] tokenList;
	}

public:
	this( CTOR_FromFile _, string filename, ExtendedIdentifier identifier ) {
		this.identifier = identifier;

		super( _, filename );
	}

public:
	const ExtendedIdentifier identifier;

	alias parsingData = _parsingData;
	@property AST_Module ast( ) {
		return parsingData.ast;
	}

	@property Symbol_UserModule symbol( ) {
		return parsingData.symbol;
	}

	@property Token[ ] tokenList( ) {
		return parsingData.tokenList;
	}

public:
	override @property string identificationString( ) const {
		return identifier.str;
	}

private:
	ParsingData obtain_parsingData( ) {
		assert( !context.lexer );

		Lexer lexer = new Lexer( this );
		context.lexer = lexer;
		scope ( exit )
			context.lexer = null;

		// If we are instructed to do only lexing phase, do it
		if ( context.project.configuration.stopOnPhase == ProjectConfiguration.StopOnPhase.lexing ) {
			while ( lexer.getNextToken != Token.Special.eof ) {
			}
			return ParsingData( null, null, lexer.generatedTokens );
		}

		// Read first token
		context.lexer.getNextToken( );

		auto ast = AST_Module.parse( );

		benforce( ast.identifier == this.identifier, E.moduleNameMismatch, "Module '" ~ ast.identifier.str ~ "' should be named '" ~this.identifier.str ~ "'", CodeLocation( this ).errGuardFunction );

		if ( context.project.configuration.stopOnPhase == ProjectConfiguration.StopOnPhase.parsing )
			return ParsingData( ast, null, lexer.generatedTokens );

		return ParsingData( ast, new Symbol_UserModule( this, ast ), lexer.generatedTokens );
	}

}

bool isValidModuleOrPackageIdentifier( string str ) {
	static auto rx = ctRegex!"^[a-z_][a-z0-9_]*$";
	return cast( bool ) str.matchFirst( rx );
}
