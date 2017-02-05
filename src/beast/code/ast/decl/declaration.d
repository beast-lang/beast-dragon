module beast.code.ast.decl.declaration;

import beast.code.ast.toolkit;
import beast.code.ast.decl.variable;
import beast.code.ast.expr.typeorauto;

abstract class AST_Declaration : ASTNode {

public:
	static bool canParse( ) {
		return AST_DecorationList.canParse || AST_TypeOrAutoExpression.canParse;
	}

	static AST_Declaration parse( AST_DecorationList parentDecorationList ) {
		const auto _gd = codeLocationGuard( );
		AST_DecorationList decorationList = parentDecorationList;

		// Decoration list
		if ( AST_DecorationList.canParse ) {
			decorationList = AST_DecorationList.parse( );
			decorationList.parentDecorationList = parentDecorationList;
		}

		return parse( _gd, decorationList );
	}

	static AST_Declaration parse( CodeLocationGuard _gd, AST_DecorationList decorationList ) {
		/// Type of variable or return type of a function
		AST_TypeOrAutoExpression type = AST_TypeOrAutoExpression.parse( );

		/// Identifier
		AST_Identifier identifier = AST_Identifier.parse( );

		// And now we decide, if it is a function or not

		// ";" || "=" => variable
		if ( currentToken == Token.Special.semicolon || currentToken == Token.Operator.assign )
			return AST_VariableDeclaration.parse( _gd, decorationList, type, identifier );
			
		assert( 0 );
	}

public:
	AST_DecorationList decorationList;

}
