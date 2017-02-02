module beast.code.module_;

import beast.toolkit;
import beast.core.project.codesource;
import beast.code.lex.lexer;
import std.regex;
import beast.code.symbol.module_;
import beast.code.ast.module_;

/// Abstraction of module in Beast (from project point of view)
final class Module : CodeSource, Identifiable {
	mixin TaskGuard!( "parsingData", ParsingData );

public:
	struct ParsingData {
		AST_Module ast;
		Symbol_Module symbol;
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

	@property Symbol_Module symbol( ) {
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
		context.lexer.getNextToken( );

		auto ast = AST_Module.parse( );

		context.lexer = null;
		benforce( ast.identifier == this.identifier, E.moduleNameMismatch, "Module '" ~ ast.identifier.str ~ "' should be named '" ~this.identifier.str ~ "'", CodeLocation( this ).errGuardFunction );

		return ParsingData( ast, new Symbol_Module( this, ast ), lexer.generatedTokens );
	}

}

bool isValidModuleOrPackageIdentifier( string str ) {
	static auto rx = ctRegex!"^[a-z_][a-z0-9_]*$";
	return cast( bool ) str.matchFirst( rx );
}
