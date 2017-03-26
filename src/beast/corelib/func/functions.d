module beast.corelib.deco.functions;

import beast.corelib.toolkit;
import beast.corelib.deco.static_;
import beast.code.data.function_.function_;
import beast.code.data.function_.primstcrt;
import beast.code.data.function_.expandedparameter;
import beast.backend.common.primitiveop;

struct CoreLibrary_Functions {

	public:
		Symbol_Function printBool;

		Symbol_Function assert_;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			auto tp = &coreLibrary.type;

			sink( printBool = new Symbol_PrimitiveStaticRuntimeFunction( ID!"print", parent, //
					tp.Void, ExpandedFunctionParameter.bootstrap( tp.Bool ), //
					BackendPrimitiveOperation.print ) );

			sink( assert_ = new Symbol_PrimitiveStaticRuntimeFunction( ID!"assert", parent, //
					tp.Void, ExpandedFunctionParameter.bootstrap( tp.Bool ), //
					BackendPrimitiveOperation.assert_ ) );
		}
}
