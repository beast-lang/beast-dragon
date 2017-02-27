module beast.code.data.var.userlocal;

import beast.code.data.toolkit;
import beast.code.data.entitycontainer.scope_.local;

final class DataEntity_UserLocalVariable : DataEntity {

public:
	this( AST_VariableDeclaration ast, DecorationList decorationList, DataScope scope_, VariableDeclarationData declData ) {
		// 
		{
		DataScope localScope_ = new LocalDataScope( scope_ );
		ast.type.buildSemanticTree( coreLibrary.types.Type, localScope_ );
		}
	}

public:
	final override AST_Node ast( ) {
		return ast_;
	}

private:
	AST_Node ast_;

}
