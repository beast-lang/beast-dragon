module beast.code.ast.decorationlist;

import beast.code.ast.toolkit;
import beast.code.ast.decoration;

/// Set of AST_Decoration
final class AST_DecorationList : ASTNode {

public:
	static bool canParse( ) {
		return AST_Decoration.canParse;
	}

	static AST_DecorationList parse( ) {
		auto result = new AST_DecorationList;

		do {
			result.list ~= AST_Decoration.parse( );
		}
		while ( AST_Decoration.canParse( ) );

		return result;
	}

public:
	AST_Decoration[ ] list;
	/// Decoration lists are in a linked list for easier parsing
	AST_DecorationList parentDecorationList;

public:
	override ASTNode[ ] subnodes( ) {
		return cast( ASTNode[ ] ) list;
	}

}
