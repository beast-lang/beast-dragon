module beast.code.data.function_.param;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.data.function_.expandedparameter;

final class DataEntity_FunctionParameter : DataEntity {

	public:
		this( ExpandedFunctionParameter param, bool isCtime ) {
			assert( param.identifier );
			assert( !param.isConstValue );

			super( MatchLevel.fullMatch );

			param_ = param;
			parent_ = currentScope.parentEntity( );
		}

	public:
		override Identifier identifier( ) {
			return param_.identifier;
		}

		override Symbol_Type dataType( ) {
			return param_.dataType;
		}

		override bool isCtime( ) {
			return isCtime;
		}

		override DataEntity parent( ) {
			return parent_;
		}

		override AST_Node ast( ) {
			return param_.ast;
		}

	public:
		override void buildCode( CodeBuilder cb ) {
			cb.build_parameterAccess( param_ );
		}

	public:
		override size_t asFunctionParameter_index( ) {
			return param_.index;
		}

	private:
		ExpandedFunctionParameter param_;
		DataEntity parent_;

}

class FunctionParameterDecorationData {

}
