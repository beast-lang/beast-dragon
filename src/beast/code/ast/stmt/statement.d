module beast.code.ast.stmt.statement;

import beast.code.ast.toolkit;
import beast.code.decorationlist;

/// Statement is anything in the function body
abstract class AST_Statement : AST_Node {
	public import beast.code.ast.decl.env : DeclarationEnvironment;

public:
	static bool canParse( ) {
		return AST_Declaration.canParse || AST_Expression.canParse;
	}

	static AST_Statement parse( AST_DecorationList decorationList ) {
		if ( currentToken == Token.Keyword.auto_ )
			return AST_Declaration.parse( decorationList );

		if( AST_Expression.canParse ) {
			AST_Expression expr = AST_Expression.parse();
		}

		currentToken.reportUnexpectedToken( "statement" );
		assert( 0 );
	}

public:
	/// Builds code representing the statement using given code builder in the given scope
	abstract void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb, DataScope scope_ );

}
