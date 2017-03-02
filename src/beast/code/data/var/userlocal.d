module beast.code.data.var.userlocal;

import beast.code.data.toolkit;
import beast.code.data.scope_.local;

final class DataEntity_UserLocalVariable : DataEntity_LocalVariable {

public:
	this( AST_VariableDeclaration ast, DecorationList decorationList, VariableDeclarationData data ) {
		ast_ = ast;

		Symbol_Type dataType;

		// Deduce data type
		{
			const auto _gd = ErrorGuard( ast.type );
			DataScope localScope_ = new LocalDataScope( data.env.scope_ );
			dataType = ast.type.buildSemanticTree( coreLibrary.types.Type, localScope_ ).ctExec_asType( localScope_ );
			localScope_.finish();
		}

		super( dataType, data.env.scope_ );
	}

public:
	final override Identifier identifier() {
		return ast_.identifier.identifier;
	}

	final override AST_Node ast( ) {
		return ast_;
	}

private:
	AST_VariableDeclaration ast_;

}
