module beast.code.ast.decl.variable;

import beast.code.ast.toolkit;
import beast.code.ast.expr.typeorauto;

final class AST_VariableDeclaration : AST_Declaration {

public:
	static bool canParse( ) {
		assert( 0 );
	}

	static AST_Declaration parse( CodeLocationGuard _gd, AST_DecorationList decorationList, AST_TypeOrAutoExpression type, AST_Identifier identifier ) {
		AST_VariableDeclaration result = new AST_VariableDeclaration;
		result.decorationList = decorationList;
		result.type = type;
		result.identifier = identifier;

		if ( currentToken == Token.Operator.assign ) {
			getNextToken( );
			result.value = AST_Expression.parse( );
		}
		else
			currentToken.expect( Token.Special.semicolon, "variable value or semicolon" );

		result.codeLocation = _gd.get( );
		return result;
	}

public:
	AST_DecorationList decorationList;
	AST_TypeOrAutoExpression type;
	AST_Identifier identifier;
	AST_Expression value;

protected:
	override InputRange!ASTNode _subnodes( ) {
		// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
		return nodeRange( type, identifier, value, ( decorationList.codeLocation.isInside( codeLocation ) ? decorationList : null ) );
	}

}
