module beast.code.ast.expr.parameterlist;

import beast.code.ast.toolkit;

/// Parameter list used in declarations
final class AST_ParameterList : AST_Node {

public:
	static bool canParse( ) {
		return currentToken == Token.Special.lParent;
	}

	static AST_ParameterList parse( ) {
		auto _gd = codeLocationGuard( );
		AST_ParameterList result = new AST_ParameterList( );

		currentToken.expect( Token.Special.lParent );
		getNextToken( );

		currentToken.expect( Token.Special.rParent );
		getNextToken( );

		result.codeLocation = _gd.get( );
		return result;
	}

protected:
	override InputRange!AST_Node _subnodes( ) {
		return nodeRange(  );
	}

}
