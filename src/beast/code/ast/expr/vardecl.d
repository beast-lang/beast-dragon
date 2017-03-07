module beast.code.ast.expr.vardecl;

import beast.code.ast.toolkit;
import beast.code.ast.identifier;

final class AST_VariableDeclarationExpression : AST_Expression {

	public:
		static bool canParse( ) {
			assert( 0 );
		}

		/// Continues parsing after "@deco Type name" part ( "= value;", ":= value;" or ";" can follow )
		static AST_VariableDeclarationExpression parse( CodeLocationGuard _gd, AST_DecorationList decorationList, AST_Expression dataType ) {
			AST_VariableDeclarationExpression result = new AST_VariableDeclarationExpression;
			result.decorationList = decorationList;
			result.dataType = dataType;

			result.identifier = AST_Identifier.parse( );

			if ( currentToken.matchAndNext( Token.Operator.assign ) ) {
				result.value = AST_Expression.parse( );
			}
			else if ( currentToken.matchAndNext( Token.Operator.colonAssign ) ) {
				result.valueColonAssign = true;
				result.value = AST_Expression.parse( );
			}

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		override AST_VariableDeclarationExpression isVariableDeclaration( ) {
			return this;
		}

	public:
		AST_DecorationList decorationList;
		AST_Expression dataType;
		AST_Identifier identifier;
		AST_Expression value;
		/// True if variable was declarated using "@deco Type name := value"
		bool valueColonAssign;

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, DataScope scope_, bool errorOnInferrationFailure = true ) {
			berror( E.notImplemented, "Inexpr variable definitions are not implemented" );
			assert( 0 );
		}

	protected:
		override SubnodesRange _subnodes( ) {
			// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
			return nodeRange( dataType, identifier, value, decorationList.codeLocation.isInside( codeLocation ) ? decorationList : null );
		}

}
