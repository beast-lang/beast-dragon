module beast.code.data.var.functionparameter;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.data.function_.expandedparameter;

final class DataEntity_FunctionParameter : DataEntity_LocalVariable {

	public:
		this( DataScope scope_, ExpandedFunctionParameter param ) {
			assert( param.identifier );
			super( param.dataType, scope_, !param.constValue.isNull, MemoryBlock.Flag.functionParameter );

			memoryBlock_.functionParameter = param;
			param_ = param;
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
