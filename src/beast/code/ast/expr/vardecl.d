module beast.code.ast.expr.vardecl;

import beast.code.ast.toolkit;
import beast.code.decorationlist;
import beast.code.ast.decl.variable;

final class AST_VariableDeclarationExpression : AST_Expression {

public:
	static bool canParse( ) {
		assert( 0 );
	}

	/// Continues parsing after "@deco Type name" part ( "= value;", ":= value;" or ";" can follow )
	static AST_VariableDeclarationExpression parse( CodeLocationGuard _gd, AST_DecorationList decorationList, AST_Expression type ) {
		AST_VariableDeclarationExpression result = new AST_VariableDeclarationExpression;

		AST_Identifier identifier = AST_Identifier.parse( );
		result.decl = AST_VariableDeclaration.parse( _hd, decorationList, type, identifier );
	}

public:
	override AST_VariableDeclarationExpression isVariableDeclaration( ) {
		return this;
	}

public:
	AST_VariableDeclaration decl;
	alias decl this;

public:
	override DataEntity buildSemanticTree( Symbol_Type expectedType, DataScope scope_, bool errorOnFailure = true ) {
		berror( E.notImplemented, "Inexpr variable definitions are not implemented" );
	}

protected:
	override InputRange!AST_Node _subnodes( ) {
		// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
		return nodeRange( decl );
	}

}
