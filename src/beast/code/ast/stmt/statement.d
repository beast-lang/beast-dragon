module beast.code.ast.stmt.statement;

import beast.code.ast.toolkit;
import beast.code.decorationlist;
import beast.code.ast.expr.typeorauto;

/// Statement is anything in the function body
abstract class AST_Statement : AST_Node {
	public import beast.code.ast.decl.env : DeclarationEnvironment;

public:
	static bool canParse( ) {
		return AST_Declaration.canParse || AST_Expression.canParse;
	}

	static AST_Statement parse( AST_DecorationList decorationList ) {
		auto _gd = codeLocationGuard( );

		if ( currentToken == Token.Keyword.auto_ )
			return AST_Declaration.parse( decorationList );

		if ( AST_Expression.canParse ) {
			AST_Expression expr = AST_Expression.parse( );

			// expr identifier => declaration
			if ( currentToken == Token.Type.identifier ) {
				benforce( expr.isP1Expression, E.unexpectedToken, "Syntax error - either unexpected identifier or type expression uses forbidden operators" );
				return AST_Declaration.parse( _gd, decorationList, new AST_TypeOrAutoExpression( expr ) );
			}

			// Otherwise just expression statement
			currentToken.expect( Token.Special.semicolon );
			return expr;
		}

		currentToken.reportUnexpectedToken( "statement" );
		assert( 0 );
	}

public:
	/// Builds code representing the statement using given code builder in the given scope
	abstract void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb, DataScope scope_ );

}
