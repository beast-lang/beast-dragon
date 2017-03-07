module beast.code.ast.decoration;

import beast.code.ast.toolkit;
import beast.code.ast.identifier;
import beast.code.util;

/// '@' identifier [ ParentCommaExpr ]
final class AST_Decoration : AST_Node {

	public:
		static bool canParse( ) {
			return currentToken == Token.Special.at;
		}

		static AST_Decoration parse( ) {
			auto result = new AST_Decoration;

			currentToken.expectAndNext( Token.Special.at );

			currentToken.expect( Token.Type.identifier, "decorator identifier" );
			result.identifier = AST_Identifier.parse( );
			result.decoratorIdentifier = result.identifier.decorationIdentifierToDecoratorIdentifier;

			return result;
		}

	public:
		AST_Identifier identifier;
		/// Decoration identifier translated to decorator identifier (see decorationIdentifierToDecoratorIdentifier)
		Identifier decoratorIdentifier;

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( identifier );
		}

}
