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
			super.initialize( );

			// TODO: pass to baseClass
			// Implicit constructor
			members ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.memZero, inst );
					} );

			// Copy/assign constructor
			members ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( coreLibrary.enum_.xxctor.opAssign, this ), //
					( cb, inst, args ) { //
						// 0th argument is #Ctor.opAssign!
						cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 1 ] );
					} );

			// Destructor
			members ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", this, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.noopDtor, inst );
					} );

			namespace_.initialize( members );
		}

	public:
		override Identifier identifier( ) {
			return identifier_;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	private:
		BootstrapNamespace namespace_;
		Identifier identifier_;

}
