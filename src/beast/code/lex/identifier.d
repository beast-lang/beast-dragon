module beast.code.lex.identifier;

import beast.code.ast.toolkit;
import beast.toolkit;

final class Identifier {

public:
	static synchronized Identifier obtain( string str ) {
		Identifier id = map.get( str, null );
		if ( id )
			return id;

		id = new Identifier( str );
		map[ str ] = id;
		return id;
	}

public:
	const string str;
	const size_t hash;
	const Token.Keyword keyword;

public:
	override size_t toHash( ) const {
		return hash;
	}

	// We don't need to compare strings, we only compare pointers
	bool opEquals( Identifier other ) const {
		return this is other;
	}

private:
	this( string str, Token.Keyword keyword = Token.Keyword._noKeyword ) {
		this.str = str;
		this.keyword = keyword;

		size_t hash_;
		foreach ( ch; str )
			hash_ = ( hash_ << 1 ) ^ 13 + ch;

		this.hash = hash_;
	}

private:
	static __gshared Identifier[ string ] map;
	enum _init = HookAppInit.hook!( {
			foreach ( i, str; Token.keywordStr[ 1 .. $ ] )
				map[ str ] = new Identifier( str, cast( Token.Keyword )( i + 1 ) );
		} );

}

/// Sequence of identifiers, abstractly in format "id1"."id2"
struct ExtendedIdentifier {

public:
	static bool canParse( ) {
		return currentToken == Token.Type.identifier;
	}

	static ExtendedIdentifier parse( ) {
		currentToken.expect( Token.Type.identifier );
		ExtendedIdentifier result;
		result ~= currentToken.identifier;

		while ( getNextToken() == Token.Special.dot ) {
			getNextToken().expect( Token.Type.identifier );
			result ~= currentToken.identifier;
		}
		
		return result;
	}

public:
	Identifier[ ] data;
	alias data this;

public:
	@property string str( ) {
		return data.map!( x => cast( string ) x.str ).joiner( "." ).to!string;
	}

}
