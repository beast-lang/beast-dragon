module beast.code.data.var.tmplocal;

import beast.code.data.toolkit;
import beast.code.data.scope_.local;
import beast.code.data.var.local;

final class DataEntity_TmpLocalVariable : DataEntity_LocalVariable {

	public:
		this( Symbol_Type dataType, bool isCtime, string memBlockId = null ) {
			super( dataType, isCtime, MemoryBlock.Flag.noFlag, memBlockId );
		}

	public:
		override AST_Node ast( ) {
			return null;
		}

}
