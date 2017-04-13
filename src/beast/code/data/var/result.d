module beast.code.data.var.result;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.data.function_.rt;

/// Data entity representing function return value
final class DataEntity_Result : DataEntity_LocalVariable {

	public:
		this( Symbol_RuntimeFunction func, Symbol_Type dataType ) {
			super( dataType, false, MemoryBlock.Flag.result );
			memoryBlock.bpOffset = -2 - func.parameters.length;
		}

	public:
		override AST_Node ast( ) {
			return null;
		}
		
}
