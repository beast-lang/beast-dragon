module beast.code.lex.token;

import beast.code.lex.identifier;
import beast.code.lex.toolkit;
import beast.core.project.codelocation;
import std.algorithm.searching : endsWith;

final class Token {

	public:
		enum Type {
			_noToken,

			identifier,
			keyword,
			operator,
			special
		}

		static immutable string[ ] typeStr = [ "", "identifier", "keyword", "operator", "" ];

		// Ugly dmft formatting
		static immutable Data[ ] typeDefaultData = [ {identifier:
		null}, {identifier:
		null}, {keyword:
		Keyword._noKeyword}, {operator:
		Operator._noOperator}, {special:
		Special._noSpecial} ];

		enum Keyword {
			_noKeyword,

			module_,
			class_,

			if_,
			else_,

			auto_
		}

		static immutable string[ ] keywordStr = {
			string[ ] result;

			foreach ( memberName; __traits( derivedMembers, Keyword ) )
				result ~= memberName.endsWith( "_" ) ? memberName[ 0 .. $ - 1 ] : memberName;

			return result;
		}( );

		enum Operator {
			_noOperator,
			add, /// '+'
			subtract, /// '-'
			multiply, /// '*'
			divide, /// '/'

			assign, /// '='
			colonAssign, /// ':='

			bitAnd, /// '&'
			bitOr, /// '|'

			logAnd, /// '&&'
			logOr, /// '||'

			dollar, /// '$'

			_length
		}

		static immutable string[ Operator._length ] operatorStr = [ null, "+", "-", "*", "/", "=", ":=", "&", "|", "&&", "||", "$" ];

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

	public:
		CodeLocation codeLocation;
		const Type type;
		Token previousToken;

	public:
		Identifier identifier( ) {
			assert( type == Type.identifier );
			return data.identifier;
		}

		Keyword keyword( ) {
			assert( type == Type.keyword );
			return data.keyword;
		}

		Operator operator( ) {
			assert( type == Type.operator );
			return data.operator;
		}

		Special special( ) {
			assert( type == Type.special );
			return data.special;
		}

	public:
		void expect( Type type, lazy string whatExpected = null ) {
			expect( type, typeDefaultData[ type ], whatExpected );
		}

		void expect( Keyword kwd, lazy string whatExpected = null ) {
			Data data = {keyword:
			kwd};
			expect( Type.keyword, data, whatExpected );
		}

		void expect( Operator op, lazy string whatExpected = null ) {
			Data data = {operator:
			op};
			expect( Type.operator, data, whatExpected );
		}

		void expect( Special sp, lazy string whatExpected = null ) {
			Data data = {special:
			sp};
			expect( Type.special, data, whatExpected );
		}

		void expect( Type type, const Data data, lazy string whatExpected = null ) {
			if ( this.type != type ) {
				string we = whatExpected;
				reportsyntaxError( we ? we : descStr( type, data ) );
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

			default:
				result = true;
				break;

			}

			if ( !result )
				reportsyntaxError( whatExpected ? whatExpected : descStr( type, data ) );
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

		void reportsyntaxError( string whatExpected ) {
			berror( E.syntaxError, "Expected %s but got %s".format( whatExpected, descStr ), codeLocation.errGuardFunction );
		}

	public:
		bool opEquals( Type t ) const {
			return type == t;
		}

		bool opEquals( Keyword kwd ) const {
			return type == Type.keyword && data.keyword == kwd;
		}

		bool opEquals( Operator op ) const {
			return type == Type.operator && data.operator == op;
		}

		bool opEquals( Special spec ) const {
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
		string descStr( ) {
			return descStr( type, data );
		}

		static string descStr( Type type, const Data data ) {
			string result = typeStr[ type ];

			switch ( type ) {

			case Type.identifier: {
					if ( data.identifier )
						result ~= " '" ~ data.identifier.str ~ "'";
				}
				break;

			case Type.keyword: {
					if ( string str = keywordStr[ cast( size_t ) data.keyword ] )
						result ~= " '" ~ str ~ "'";
				}
				break;

			case Type.operator: {
					if ( string str = operatorStr[ cast( int ) data.operator ] )
						result ~= " '" ~ str ~ "'";
				}
				break;

			case Type.special: {
					result ~= specialStr[ cast( int ) data.operator ];
				}
				break;

			default:
				break;

			}

			return result;
		}

	private:
		union Data {
			Identifier identifier;
			Keyword keyword;
			Operator operator;
			Special special;
		}

		Data data;

}
