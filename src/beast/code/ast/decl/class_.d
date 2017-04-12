module beast.code.ast.decl.class_;

import beast.code.ast.decl.toolkit;
import beast.code.ast.decl.declarationscope;
import beast.code.ast.decoration;
import beast.code.ast.identifier;
import beast.code.data.type.usrstcclass;

final class AST_Class : AST_Declaration {

	public:
		static bool canParse( ) {
			return currentToken == Token.Keyword.class_;
		}

		static AST_Class parse( ) {
			auto clg = codeLocationGuard( );
			auto result = new AST_Class;

			// class X { ... };
			currentToken.expectAndNext( Token.Keyword.class_ );
			result.identifier = AST_Identifier.parse( );
			currentToken.expectAndNext( Token.Special.lBrace );
			result.declarationScope = AST_DeclarationScope.parse( );
			currentToken.expectAndNext( Token.Special.rBrace );

			result.codeLocation = clg.get( );
			return result;
		}

	public:
		AST_Identifier identifier;
		AST_DeclarationScope declarationScope;

	public:
		override void executeDeclarations( DeclarationEnvironment env, void delegate( Symbol ) sink ) {
			const auto __gd = ErrorGuard( codeLocation );

			auto declData = new ClassDeclarationData( env );
			DecorationList decorations = new DecorationList( decorationList );

			// Apply possible decorators in the variableDeclarationModifier context
			decorations.apply_classDeclarationModifier( declData );

			if ( declData.isCtime || !declData.isStatic )
				berror( E.notImplemented, "Ctime classes not implemented yet" );
			else {
				auto class_ = new Symbol_UserStaticClass( this, decorations, declData );
				class_.initialize( );
				sink( class_ );
			}
		}

		override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb ) {
			berror( E.notImplemented, "Scope classes are not implemented yet" );
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( declarationScope );
		}

}

final class ClassDeclarationData {

	public:
		this( DeclarationEnvironment env ) {
			this.env = env;

			isCtime = env.isCtime;
			isStatic = env.isStatic;
		}

	public:
		DeclarationEnvironment env;

	public:
		bool isCtime;
		bool isStatic;

}
