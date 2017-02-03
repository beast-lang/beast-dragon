module beast.code.ast.decl.declarationscope;

import beast.code.ast.toolkit;

/// Module or class level declaration scope
final class AST_DeclarationScope : ASTNode {

public:
	static AST_DeclarationScope parse( AST_DecorationList rootDecorationList = null ) {
		auto clg = codeLocationGuard( );
		auto result = new AST_DeclarationScope;

		/// Current main scope decorations ( @decorator: xxx )
		AST_DecorationList scopeDecorationList = rootDecorationList;

		// TODO: implementation
		while ( true ) {

			// @decor @decor (something)
			if ( AST_DecorationList.canParse ) {
				AST_DecorationList decorationList = AST_DecorationList.parse( );

				// @decor :
				if ( currentToken == Token.Special.colon ) {
					decorationList.parentDecorationList = rootDecorationList;
					scopeDecorationList = decorationList;
					result.commonDecorationLists_ ~= decorationList;
				}

				// @decor { xx }
			else if ( currentToken == Token.Special.lBrace ) {
					decorationList.parentDecorationList = scopeDecorationList;

					getNextToken( );

					AST_DeclarationScope subScope = AST_DeclarationScope.parse( decorationList );
					result.subScopes_ ~= subScope;
					result.allDeclarations_ ~= subScope.allDeclarations_;

					currentToken.expect( Token.Special.rBrace, "declaration or '}'" );
					getNextToken( );
				}

				// @decor declaration;
			else if ( AST_Declaration.canParse ) {
					decorationList.parentDecorationList = scopeDecorationList;

					AST_Declaration declaration = AST_Declaration.parse( decorationList );
					result.directDeclarations_ ~= declaration;
				}

				else
					currentToken.reportUnexpectedToken( "':', '{' or declaration" );
			}

			// Declaration
			else if ( AST_Declaration.canParse ) {
				AST_Declaration declaration = AST_Declaration.parse( scopeDecorationList );
				result.directDeclarations_ ~= declaration;
			}

			// { block }
			else if ( currentToken == Token.Special.lBrace ) {
				getNextToken( );

				AST_DeclarationScope subScope = AST_DeclarationScope.parse( scopeDecorationList );
				result.subScopes_ ~= subScope;
				result.allDeclarations_ ~= subScope.allDeclarations_;

				currentToken.expect( Token.Special.rBrace, "declaration or '}'" );
				getNextToken( );
			}

			break;
		}

		result.allDeclarations_ ~= result.directDeclarations_;

		result.codeLocation = clg.get( );
		return result;
	}

protected:
	override InputRange!ASTNode _subnodes( ) {
		return nodeRange( directDeclarations_, commonDecorationLists_, subScopes_ );
	}

private:
	/// Declarations directly placed in the current declaration scope 
	AST_Declaration[ ] directDeclarations_; /// Declarations placed in the current declaration scope and its subscopes
	AST_Declaration[ ] allDeclarations_; /// Scope and block decoration lists
	AST_DecorationList[ ] commonDecorationLists_; /// Child scopes
	AST_DeclarationScope[ ] subScopes_;

}
