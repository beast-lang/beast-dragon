module beast.code.ast.decl.variable;

import beast.code.ast.decl.toolkit;
import beast.code.sym.var.user;

final class AST_VariableDeclaration : AST_Declaration {

public:
	static bool canParse( ) {
		assert( 0 );
	}

	/// Continues parsing after "@deco Type name" part ( "= value;", ":= value;" or ";" can follow )
	static AST_Declaration parse( CodeLocationGuard _gd, AST_DecorationList decorationList, AST_TypeOrAutoExpression type, AST_Identifier identifier ) {
		AST_VariableDeclaration result = new AST_VariableDeclaration;
		result.decorationList = decorationList;
		result.type = type;
		result.identifier = identifier;

		if ( currentToken == Token.Operator.assign ) {
			getNextToken( );
			result.value = AST_Expression.parse( );
		}
		else if ( currentToken == Token.Operator.colonAssign ) {
			getNextToken( );
			result.valueColonAssign = true;
			result.value = AST_Expression.parse( );
		}
		else
			currentToken.expect( Token.Special.semicolon, "default value or ';'" );

		result.codeLocation = _gd.get( );
		return result;
	}

public:
	override void executeDeclarations( void delegate( Symbol ) sink ) {
		sink( new Symbol_UserVariable( this ) );
	}

public:
	AST_DecorationList decorationList;
	AST_TypeOrAutoExpression type;
	AST_Identifier identifier;
	AST_Expression value;
	/// True if variable was declarated using "@deco Type name := value"
	bool valueColonAssign;

protected:
	override InputRange!AST_Node _subnodes( ) {
		// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
		return nodeRange( type, identifier, value, decorationList.codeLocation.isInside( codeLocation ) ? decorationList : null );
	}

}
