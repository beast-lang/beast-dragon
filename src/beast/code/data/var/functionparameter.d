module beast.code.data.var.functionparameter;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.data.function_.expandedparameter;

final class DataEntity_FunctionParameter : DataEntity_LocalVariable {

	public:
		this( ExpandedFunctionParameter param, bool isCtime ) {
			assert( param.identifier );
			assert( !param.isConstValue );

			super( param.dataType );
			allocate_( isCtime, MemoryBlock.Flag.functionParameter );

			param_ = param;

			// Context pointer is always bp offset -1 (even if there is no context needed
			// Function parameters always start on -2
			// Return value is before function parameters
			// Even expanded parameters take up some space

			memoryBlock.bpOffset = -param.index - 2;
		}

	public:
		override Identifier identifier( ) {
			return param_.identifier;
		}

		override AST_Node ast( ) {
			return param_.ast;
		}

	public:
		override size_t asFunctionParameter_index( ) {
			return -memoryBlock.bpOffset - 2;
		}

	public:
		override void allocate( bool isCtime ) {
			// Allocation is done in constructor
			assert( 0 );
		}

	private:
		ExpandedFunctionParameter param_;

}
