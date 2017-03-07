module beast.code.ast.decorationlist;

import beast.code.ast.toolkit;

/// Set of AST_Decoration
final class AST_DecorationList : AST_Node {

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

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( list );
		}

}
