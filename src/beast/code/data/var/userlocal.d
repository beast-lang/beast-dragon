module beast.code.data.var.userlocal;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.decorationlist;
import beast.code.ast.decl.variable;
import beast.code.ast.expr.vardecl;
import beast.code.ast.expr.expression;
import beast.code.data.scope_.local;

final class DataEntity_UserLocalVariable : DataEntity_LocalVariable {

	public:
		this( AST_VariableDeclaration ast, DecorationList decorationList, VariableDeclarationData data ) {
			ast_ = ast;
			identifier_ = ast.identifier.identifier;
			this( ast.dataType, decorationList, data );
		}

		this( AST_VariableDeclarationExpression ast, DecorationList decorationList, VariableDeclarationData data ) {
			ast_ = ast;
			identifier_ = ast.identifier.identifier;
			this( ast.dataType, decorationList, data );
		}

		private this( AST_Expression typeExpression, DecorationList decorationList, VariableDeclarationData data ) {
			const auto _gd = ErrorGuard( this );

			Symbol_Type dataType;

			// Deduce data type
			{
				DataScope localScope_ = new LocalDataScope( data.env.scope_ );
				dataType = typeExpression.buildSemanticTree_single( coreLibrary.type.Type, localScope_ ).ctExec_asType( localScope_ );
				localScope_.finish( );
			}

			super( dataType, data.env.scope_, data.isCtime );

			decorationList.enforceAllResolved( );
		}

	public:
		final override Identifier identifier( ) {
			return identifier_;
		}

		final override AST_Node ast( ) {
			return ast_;
		}

	private:
		Identifier identifier_;
		AST_Node ast_;

}
