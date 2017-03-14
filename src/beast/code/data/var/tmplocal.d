module beast.code.data.var.tmplocal;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.decorationlist;
import beast.code.ast.decl.variable;
import beast.code.ast.expr.vardecl;
import beast.code.ast.expr.expression;
import beast.code.data.scope_.local;

final class DataEntity_TmpLocalVariable : DataEntity_LocalVariable {

	public:
		this( Symbol_Type dataType, DataScope scope_, bool isCtime ) {
			super( dataType, scope_, isCtime );
		}

	public:
		override AST_Node ast( ) {
			return null;
		}

}
