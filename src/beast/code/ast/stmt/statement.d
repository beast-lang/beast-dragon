module beast.code.ast.stmt.statement;

import beast.code.ast.toolkit;
import beast.code.ast.decl.declaration;
import beast.code.ast.stmt.return_;

/// Statement is anything in the function body
abstract class AST_Statement : AST_Node {

	public:
		static bool canParse( ) {
			return AST_Declaration.canParse || AST_Expression.canParse || AST_ReturnStatement.canParse;
		}

		static AST_Statement parse( AST_DecorationList decorationList ) {
			auto _gd = codeLocationGuard( );

			if ( AST_DecorationList.canParse ) {
				AST_DecorationList newDecorationList = AST_DecorationList.parse( );
				newDecorationList.parentDecorationList = decorationList;
				decorationList = newDecorationList;
			}

			if ( currentToken == Token.Keyword.auto_ )
				return AST_Declaration.parse( decorationList );

			else if ( AST_ReturnStatement.canParse )
				return AST_ReturnStatement.parse( _gd, decorationList );

			else if ( AST_Expression.canParse ) {
				AST_Expression expr = AST_Expression.parse( false );

				// expr identifier => declaration
				if ( currentToken == Token.Type.identifier ) {
					benforce( expr.isUnaryExpression, E.syntaxError, "Syntax error - either unexpected identifier or type expression uses forbidden operators", ( msg ) { msg.codeLocation = currentToken.codeLocation; } );

					return AST_Declaration.parse( _gd, decorationList, expr );
				}

				benforce( decorationList is null, E.invalidDecoration, "Decorating expressions is not allowed", ( msg ) { msg.codeLocation = currentToken.codeLocation; } );

				// Otherwise just expression statement
				currentToken.expectAndNext( Token.Special.semicolon, "semicolon after expression" );
				return expr;
			}

			currentToken.reportSyntaxError( "statement" );
			assert( 0 );
		}

	public:
		/// Builds code representing the statement using given code builder in the given scope
		abstract void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb );

}
