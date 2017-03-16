module beast.code.data.type.btspenum;

import beast.code.data.toolkit;
import beast.code.data.codenamespace.namespace;
import beast.code.data.codenamespace.bootstrap;
import beast.code.data.type.enum_;
import beast.code.data.type.stcclass;
import beast.code.data.function_.btspmemrt;
import beast.code.data.function_.primmemrt;
import beast.code.data.function_.expandedparameter;
import beast.backend.common.primitiveop;

final class Symbol_BootstrapEnum : Symbol_Enum {

	public:
		this( DataEntity parent, Identifier identifier, Symbol_StaticClass baseClass ) {
			// This code must be before super call, as super constructor calls identifier
			identifier_ = identifier;

			super( parent, baseClass );
			assert( identifier );

			namespace_ = new BootstrapNamespace( this );
		}

		void initialize( Symbol[ ] members ) {
			// TODO: pass to baseClass
			members ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					BackendPrimitiveOperation.intCtor );

			members ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( coreLibrary.enum_.xxctor.copy, this ), //
					BackendPrimitiveOperation.intCopyCtor );

			members ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", this, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					BackendPrimitiveOperation.noopDtor );

			namespace_.initialize( members );
		}

	public:
		override Identifier identifier( ) {
			return identifier_;
		}

		override size_t instanceSize( ) {
			return baseClass_.instanceSize;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	private:
		BootstrapNamespace namespace_;
		Identifier identifier_;

}
