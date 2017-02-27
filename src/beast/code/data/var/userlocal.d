module beast.code.data.var.userlocal;

import beast.code.data.toolkit;
import beast.code.data.scope_.local;

final class DataEntity_UserLocalVariable : DataEntity {

public:
	this( AST_VariableDeclaration ast, DecorationList decorationList, DataScope scope_, VariableDeclarationData declData ) {
		// Deduce data type
		{
			DataScope localScope_ = new LocalDataScope( scope_ );
			dataType_ = ast.type.buildSemanticTree( coreLibrary.types.Type, localScope_ ).ctExec_asType( localScope_ );
		}
	}

public:
	final override Symbol_Type dataType() {
		return dataType_;
	}

	final override AST_Node ast( ) {
		return ast_;
	}

private:
	Symbol_Type dataType_;
	AST_Node ast_;

}
