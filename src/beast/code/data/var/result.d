module beast.code.data.var.result;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.data.function_.rt;

/// Data entity representing function return value
final class DataEntity_Result : DataEntity_LocalVariable {

	public:
		this( Symbol_RuntimeFunction func, bool isCtime, Symbol_Type dataType ) {
			super( dataType );
			allocate_( isCtime, MemoryBlock.Flag.result );

			memoryBlock.bpOffset = -2 - func.parameters.length;
			memoryBlock.identifier = "result";
		}

	public:
		override AST_Node ast( ) {
			return null;
		}

	public:
		override void allocate( bool isCtime ) {
			// Allocation is done in constructor
			assert( 0 );
		}

}
