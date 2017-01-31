module beast.code.ast.declarationscope;

import beast.code.ast.toolkit;
import beast.code.ast.decorationlist;

/// Module or class level declaration scope
final class AST_DeclarationScope : ASTNode {

public:
	static AST_DeclarationScope parse( AST_DecorationList decorationList = null ) {
		auto clg = codeLocationGuard( );
		auto result = new AST_DeclarationScope;

		/// Current main scope decorations ( @decorator: xxx )
		AST_DecorationList scopeDecorationList = decorationList;

		// TODO: implementation
		while ( true ) {
			if ( AST_DecorationList.canParse ) {
				AST_DecorationList list = AST_DecorationList.parse( );

				if ( currentToken == Token.Special.colon ) {
					scopeDecorationList = list;
					list.parentDecorationList = decorationList;

				}
				else if ( currentToken == Token.Special.lBrace ) {
					// TODO: add to list
					getNextToken( );
					AST_DeclarationScope item = AST_DeclarationScope.parse( );
					currentToken.expect( Token.Special.rBrace, "declaration or '}'" );
					getNextToken( );
				}
				xx

				continue;
			}

			break;
		}

		result.codeLocation = clg.get( );

		return result;
	}

public:

public:
	override ASTNode[ ] subnodes( ) {
		return [ ];
	}

}
