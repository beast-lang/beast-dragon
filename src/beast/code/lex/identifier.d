module beast.code.lex.identifier;

import beast.code.ast.toolkit;
import beast.toolkit;

final class Identifier {

public:
	static synchronized Identifier obtain( string str ) {
		if ( Identifier result = map.get( str, null ) )
			return result;

		Identifier result = new Identifier( str );
		map[ str ] = result;
		return result;
	}

	/// Returns an identifier for a given string that is automatically obtained on application start
	template preobtained( string str ) {
		shared static this( ) {
			preobtained = Identifier.obtain( str );
		}

		static __gshared Identifier preobtained;
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
	shared static this( ) {
		// Pregenerate identifiers for keywords
		foreach ( i, str; Token.keywordStr[ 1 .. $ ] )
			map[ str ] = new Identifier( str, cast( Token.Keyword )( i + 1 ) );
	}

}

/// Sequence of identifiers, abstractly in format "id1"."id2"
struct ExtendedIdentifier {

public:
	template preobtained( string str ) {
		static __gshared ExtendedIdentifier preobtained;
		shared static this( ) {
			preobtained = str.splitter( "." ).map!( x => Identifier.obtain( x ) ).array.ExtendedIdentifier;
		}
	}

public:
	static bool canParse( ) {
		return currentToken == Token.Type.identifier;
	}

	/// Returns an extendedIdentifier for a given string (split by '.') that is automatically obtained on application start
	static ExtendedIdentifier parse( ) {
		currentToken.expect( Token.Type.identifier );
		ExtendedIdentifier result;
		result ~= currentToken.identifier;

		while ( getNextToken( ) == Token.Special.dot ) {
			getNextToken( ).expect( Token.Type.identifier );
			result ~= currentToken.identifier;
		}

		return result;
	}

public:
	Identifier[ ] data;
	alias data this;

public:
	string str( ) {
		return data.map!( x => cast( string ) x.str ).joiner( "." ).to!string;
	}

}
