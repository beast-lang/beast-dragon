module beast.code.data.var.functionparameter;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.data.function_.expandedparameter;

final class DataEntity_FunctionParameter : DataEntity_LocalVariable {

	public:
		this( ExpandedFunctionParameter param ) {
			assert( param.identifier );
			super( param.dataType, param.isConstValue, MemoryBlock.Flag.functionParameter );

			memoryBlock_.functionParameter = param;
			param_ = param;

			// Context pointer is always bp offset -1 (even if there is no context needed
			// Function parameters always start on -2
			// Return value is before function parameters
			// Even expanded parameters take up some space

			interpreterBpOffset = -param.index - 2;
		}

	public:
		override Identifier identifier( ) {
			return param_.identifier;
		}

		override AST_Node ast( ) {
			return param_.ast;
		}

	private:
		ExpandedFunctionParameter param_;

}
