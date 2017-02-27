module beast.code.ast.stmt.codeblock;

import beast.code.ast.toolkit;
import beast.code.decorationlist;
import beast.code.ast.stmt.statement;

final class AST_CodeBlockStatement : AST_Statement {

public:
	static bool canParse( ) {
		return currentToken == Token.Special.lBrace;
	}

	static AST_CodeBlockStatement parse( ) {
		return parse( codeLocationGuard( ), null );
	}

	/// Continues parsing after decoration list
	static AST_CodeBlockStatement parse( CodeLocationGuard _gd, AST_DecorationList decorationList ) {
		auto result = new AST_CodeBlockStatement;
		result.decorationList = decorationList;

		currentToken.expect( Token.Special.lBrace );
		getNextToken( );

		currentToken.expect( Token.Special.rBrace );
		getNextToken( );

		result.codeLocation = _gd.get( );
		return result;
	}

public:
	override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb, DataScope scope_ ) {
		foreach ( stmt; subStatements )
			stmt.buildStatementCode( env, cb, scope_ );
	}

public:
	AST_DecorationList decorationList;
	AST_Statement[ ] subStatements;

protected:
	override InputRange!AST_Node _subnodes( ) {
		// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
		return nodeRange( subStatements, decorationList.codeLocation.isInside( codeLocation ) ? decorationList : null );
	}

}
