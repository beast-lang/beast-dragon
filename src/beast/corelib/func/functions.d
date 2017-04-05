module beast.corelib.deco.functions;

import beast.corelib.toolkit;
import beast.corelib.deco.static_;
import beast.code.data.function_.function_;
import beast.code.data.function_.primstcrt;
import beast.code.data.function_.expandedparameter;
import beast.backend.common.primitiveop;
import beast.code.data.var.tmplocal;

struct CoreLibrary_Functions {

	public:
		Symbol_Function printBool, printInt;

		Symbol_Function malloc, free;

		Symbol_Function assert_;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			auto tp = &coreLibrary.type;

			sink( printBool = new Symbol_PrimitiveStaticRuntimeFunction( ID!"print", parent, //
					tp.Void, ExpandedFunctionParameter.bootstrap( tp.Bool ), //
					( cb, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.print, args[ 0 ] );
					} ) );
			sink( printInt = new Symbol_PrimitiveStaticRuntimeFunction( ID!"print", parent, //
					tp.Void, ExpandedFunctionParameter.bootstrap( tp.Int32 ), //
					( cb, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.print, args[ 0 ] );
					} ) );

			sink( malloc = new Symbol_PrimitiveStaticRuntimeFunction( ID!"malloc", parent, //
					tp.Pointer, ExpandedFunctionParameter.bootstrap( tp.Size ), //
					( cb, args ) { //
						auto result = new DataEntity_TmpLocalVariable( tp.Pointer, cb.isCtime );
						cb.build_localVariableDefinition( result );
						cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, result );
						cb.build_primitiveOperation( BackendPrimitiveOperation.malloc, result, args[ 0 ] );

						// Result data
						result.buildCode( cb );
					} ) );
			sink( malloc = new Symbol_PrimitiveStaticRuntimeFunction( ID!"free", parent, //
					tp.Void, ExpandedFunctionParameter.bootstrap( tp.Pointer ), //
					( cb, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.free, args[ 0 ] );
					} ) );

			sink( assert_ = new Symbol_PrimitiveStaticRuntimeFunction( ID!"assert", parent, //
					tp.Void, ExpandedFunctionParameter.bootstrap( tp.Bool ), //
					( cb, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.assert_, args[ 0 ] );
					} ) );
		}
}
