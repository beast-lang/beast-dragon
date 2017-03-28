module beast.code.lex.token;

import beast.code.lex.identifier;
import beast.code.lex.toolkit;
import beast.core.project.codelocation;
import std.algorithm.searching : endsWith;
import std.bigint;

final class Token {

	public:
		enum Type {
			_noToken,

			identifier,
			keyword,
			operator,
			special,
			literal,
		}

		// Ugly dmft formatting
		static immutable Data[ ] typeDefaultData = [ {identifier:
		null}, {identifier:
		null}, {keyword:
		Keyword._noKeyword}, {operator:
		Operator._noOperator}, {special:
		Special._noSpecial}, {literal:
		null} ];

		enum Keyword {
			_noKeyword,

			module_,
			class_,

			if_,
			else_,
			while_,

			auto_,
			break_,
			return_
		}

		static immutable string[ ] keywordStr = {
			string[ ] result;

			foreach ( memberName; __traits( derivedMembers, Keyword ) )
				result ~= memberName.endsWith( "_" ) ? memberName[ 0 .. $ - 1 ] : memberName;

			return result;
		}( );

		enum Operator {
			_noOperator,
			plus, /// '+'
			minus, /// '-'
			multiply, /// '*'
			divide, /// '/'

			assign, /// '='
			colonAssign, /// ':='

			bitAnd, /// '&'
			bitOr, /// '|'

			logAnd, /// '&&'
			logOr, /// '||'

			dollar, /// '$'

			questionMark, /// '?'
			exclamationMark, /// '!'

			_length
		}

		static immutable string[ Operator._length ] operatorStr = [ null, "+", "-", "*", "/", "=", ":=", "&", "|", "&&", "||", "$", "?", "!" ];

		enum Special {
			_noSpecial,
			eof,

			dot, /// '.'
			comma, /// ','
			semicolon, /// ';'
			colon, /// ':'

			at, /// '@'

			lBracket, /// '['
			rBracket, /// ']'
			lBrace, /// '{'
			rBrace, /// '}'
			lParent, /// '('
			rParent, /// ')'

			_length
		}

		static immutable string[ Special._length ] specialStr = [ "", "EOF", "dot '.'", "','", "semicolon ';'", "':'", "'@'", "'['", "']'", "'{'", "'}'", "'('", "')'" ];

	public:
		this( Special special ) {
			this( );
			type = Type.special;
			data.special = special;
		}

		this( Identifier identifier ) {
			this( );
			type = Type.identifier;
			data.identifier = identifier;
		}

		this( Keyword keyword ) {
			this( );
			type = Type.keyword;
			data.keyword = keyword;
		}

		this( Operator operator ) {
			this( );
			type = Type.operator;
			data.operator = operator;
		}

		this( DataEntity literal ) {
			this( );
			type = Type.literal;
			data.literal = literal;
		}

	public:
		CodeLocation codeLocation;
		const Type type;
		Token previousToken;

	public:
		pragma( inline ) Identifier identifier( ) {
			assert( type == Type.identifier );
			return data.identifier;
		}

		pragma( inline ) Keyword keyword( ) {
			assert( type == Type.keyword );
			return data.keyword;
		}

		pragma( inline ) Operator operator( ) {
			assert( type == Type.operator );
			return data.operator;
		}

		pragma( inline ) Special special( ) {
			assert( type == Type.special );
			return data.special;
		}

		pragma( inline ) DataEntity literal( ) {
			assert( type == Type.literal );
			return data.literal;
		}

	public:
		pragma( inline ) void expect( Type type, lazy string whatExpected = null ) {
			expect( type, typeDefaultData[ type ], whatExpected );
		}

		pragma( inline ) void expect( Keyword kwd, lazy string whatExpected = null ) {
			Data data = {keyword:
			kwd};
			expect( Type.keyword, data, whatExpected );
		}

		pragma( inline ) void expect( Operator op, lazy string whatExpected = null ) {
			Data data = {operator:
			op};
			expect( Type.operator, data, whatExpected );
		}

		pragma( inline ) void expect( Special sp, lazy string whatExpected = null ) {
			Data data = {special:
			sp};
			expect( Type.special, data, whatExpected );
		}

		void expect( Type type, const Data data, lazy string whatExpected = null ) {
			if ( this.type != type ) {
				string we = whatExpected;
				reportSyntaxError( we ? we : descStr( type, data ) );
			}

			bool result;

			switch ( type ) {

			case Type.keyword:
				result = data.keyword == Keyword._noKeyword || this.data.keyword == data.keyword;
				break;

			case Type.operator:
				result = data.operator == Operator._noOperator || this.data.operator == data.operator;
				break;

			case Type.special:
				result = data.special == Special._noSpecial || this.data.special == data.special;
				break;

			case Type.literal:
				result = true;
				break;

			default:
				result = true;
				break;

			}

			if ( !result )
				reportSyntaxError( whatExpected ? whatExpected : descStr( type, data ) );
		}

		/// Equivalent of expect( xxx ); getNextToken();
		pragma( inline ) void expectAndNext( Args... )( Args args ) {
			expect( args );
			getNextToken( );
		}

		/// If the current token matches the match, calls getNextToken and returns true
		pragma( inline ) bool matchAndNext( T )( T match ) {
			bool result = this == match;
			if ( result )
				getNextToken( );

			return result;
		}

		pragma( inline ) void reportSyntaxError( string whatExpected ) {
			berror( E.syntaxError, "Expected %s but got %s".format( whatExpected, descStr ), codeLocation.errGuardFunction );
		}

	public:
		pragma( inline ) bool opEquals( Type t ) const {
			return type == t;
		}

		pragma( inline ) bool opEquals( Keyword kwd ) const {
			return type == Type.keyword && data.keyword == kwd;
		}

		pragma( inline ) bool opEquals( Operator op ) const {
			return type == Type.operator && data.operator == op;
		}

		pragma( inline ) bool opEquals( Special spec ) const {
			return type == Type.special && data.special == spec;
		}

	private:
		this( ) {
			assert( lexer );
			codeLocation.source = lexer.source;
			codeLocation.startPos = lexer.tokenStartPos;
			codeLocation.length = lexer.pos - lexer.tokenStartPos;
			type = Type._noToken;
		}

	public:
		pragma( inline ) string descStr( ) {
			return descStr( type, data );
		}

		static string descStr( Type type, const Data data ) {
			switch ( type ) {

			case Type.identifier:
				return "identifier%s".format( data.identifier ? " '%s'".format( data.identifier.str ) : null );

			case Type.keyword:
				return "keyword%s".format( data.keyword ? " '%s'".format( keywordStr[ cast( size_t ) data.keyword ] ) : null );

			case Type.operator:
				return "keyword%s".format( data.operator ? " '%s'".format( operatorStr[ cast( size_t ) data.operator ] ) : null );

			case Type.special:
				return specialStr[ cast( int ) data.special ];

			case Type.literal:
				return "literal";

			default:
				return null;

			}
		}

	private:
		union Data {
			Identifier identifier;
			Keyword keyword;
			Operator operator;
			Special special;
			DataEntity literal;
		}

		Data data;

}
