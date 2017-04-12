module beast.corelib.type.pointer;

import beast.corelib.type.toolkit;
import beast.code.hwenv.hwenv;
import beast.code.data.function_.primmemnrt;
import beast.code.data.util.reinterpret;
import beast.code.data.util.deref;

final class Symbol_Type_Pointer : Symbol_StaticClass {

	public:
		this( DataEntity parent ) {
			// Identifier must be available
			super( parent );

			parent_ = parent;
			instanceSize_ = hardwareEnvironment.pointerSize;
			namespace_ = new BootstrapNamespace( this );
		}

		override void initialize( ) {
			super.initialize( );

			Symbol[ ] mem;
			auto tp = &coreType;

			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveAssignOp( this ); // a = b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( this, coreLibrary.enum_.operator.binPlus, BackendPrimitiveOperation.intAdd ); // a + b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveBinaryOp( this, coreLibrary.enum_.operator.binMinus, BackendPrimitiveOperation.intSub ); // a - b

			{
				auto ops = Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveEqNeqOp( this ); // a == b, a != b
				opBinary_equals = ops[ 0 ];
				opBinary_notEquals = ops[ 1 ];
				mem ~= ops;
			}

			// TODO: other comparison

			// Implicit constructor
			mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreType.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, inst );
						cb.build_primitiveOperation( BackendPrimitiveOperation.memZero, inst );
					} );

			// Copy ctor
			mem ~= copyCtor = new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreType.Void, //
					ExpandedFunctionParameter.bootstrap( this ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, inst );
						cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 0 ] );
					} );

			// Dtor
			mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", this, coreType.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.unmarkPtr, inst );
						cb.build_primitiveOperation( BackendPrimitiveOperation.noopDtor, inst );
					} );

			// Explicit cast to reference
			mem ~= new Symbol_PrimitiveMemberNonRuntimeFunction( ID!"#explicitCast", this, //
					Symbol_PrimitiveMemberNonRuntimeFunction.paramsBuilder( ).ctArg( coreType.Type ).finishIf(  //
						( DataEntity inst, MemoryPtr targetType ) => targetType.readType.isReferenceType ? null : "argument 1 is not a reference type", //
						( AST_Node, DataEntity inst, MemoryPtr targetType ) => new DataEntity_ReinterpretCast( inst, targetType.readType ) //
						 ) );

			// .data( Type )
			mem ~= new Symbol_PrimitiveMemberNonRuntimeFunction( ID!"data", this, //
					Symbol_PrimitiveMemberNonRuntimeFunction.paramsBuilder( ).ctArg( coreType.Type ).finish(  //
						( AST_Node, DataEntity inst, MemoryPtr targetType ) => new DataEntity_DereferenceProxy( inst, targetType.readType ) //
					 ) );

			namespace_.initialize( mem );
		}

	public:
		override Identifier identifier( ) {
			return ID!"Pointer";
		}

		override size_t instanceSize( ) {
			return instanceSize_;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	public:
		Symbol_PrimitiveMemberRuntimeFunction copyCtor;
		Symbol opBinary_equals, opBinary_notEquals;

	private:
		BootstrapNamespace namespace_;
		DataEntity parent_;
		size_t instanceSize_;

}
