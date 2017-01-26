module beast.lex.identifier;

import std.algorithm;
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
			foreach ( mem; __traits( derivedMembers, Token.Keyword ) ) {
				string kwd = mem.endsWith( "_" ) ? mem[ 0 .. $ - 1 ] : mem;
				map[ kwd ] = new Identifier( kwd, __traits( getMember, Token.Keyword, mem ) );
			}
		} );

}
