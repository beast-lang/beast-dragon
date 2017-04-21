module beast.corelib.type.int_;

import beast.corelib.type.toolkit;

final class Symbol_Type_Int : Symbol_StaticClass {

	public:
		this( DataEntity parent, Identifier identifier, size_t instanceSize, bool signed ) {
			assert( instanceSize == 1 || instanceSize == 2 || instanceSize == 4 || instanceSize == 8 );

			// This code must be before super call, as super constructor calls identifier
			identifier_ = identifier;
			instanceSize_ = instanceSize;
			signed_ = signed;

			super( parent );
			assert( identifier );

			namespace_ = new BootstrapNamespace( this );
		}

		override void initialize( ) {
			super.initialize( );

			Symbol[ ] mem;

			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCtor( this ); // Implicit constructor
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCopyCtor( this ); // Copy constructor
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newNoopDtor( this ); // Destructor

			// Operator overloads
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveAssignOp( this ); // a = b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalEqNeqOp( this ); // a == b, a != b

			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalBinaryOp( this, coreType.Bool, coreEnum.operator.binGt, BackendPrimitiveOperation.intGt ); // a > b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalBinaryOp( this, coreType.Bool, coreEnum.operator.binGte, BackendPrimitiveOperation.intGte ); // a >= b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalBinaryOp( this, coreType.Bool, coreEnum.operator.binLt, BackendPrimitiveOperation.intLt ); // a < b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalBinaryOp( this, coreType.Bool, coreEnum.operator.binLte, BackendPrimitiveOperation.intLte ); // a <= b

			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalBinaryOp( this, coreEnum.operator.binPlus, BackendPrimitiveOperation.intAdd ); // a + b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalBinaryOp( this, coreEnum.operator.binMinus, BackendPrimitiveOperation.intSub ); // a - b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalBinaryOp( this, coreEnum.operator.binMult, BackendPrimitiveOperation.intMult ); // a * b
			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveSymmetricalBinaryOp( this, coreEnum.operator.binDiv, BackendPrimitiveOperation.intDiv ); // a / b

			switch ( instanceSize_ + signed_ * 100 ) {

				// Int32
			case 104: {
					mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveImplicitCast( this, coreType.Int64, BackendPrimitiveOperation.int32To64 ); // Implicit cast to Int64
					break;
				}

			default:
				break;

			}

			namespace_.initialize( mem );
		}

	public:
		override Identifier identifier( ) {
			return identifier_;
		}

		override size_t instanceSize( ) {
			return instanceSize_;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	public:
		override Symbol_Type_Int isIntType( ) {
			return this;
		}

	public:
		override string valueIdentificationString( MemoryPtr value ) {
			switch ( instanceSize_ + signed_ * 100 ) {

				// UNSIGNED:
			case 1:
				return value.readPrimitive!ubyte.to!string;

			case 2:
				return value.readPrimitive!ushort.to!string;

			case 4:
				return value.readPrimitive!uint.to!string;

			case 8:
				return value.readPrimitive!ulong.to!string;

				// SIGNED:
			case 101:
				return value.readPrimitive!byte.to!string;

			case 102:
				return value.readPrimitive!short.to!string;

			case 104:
				return value.readPrimitive!int.to!string;

			case 108:
				return value.readPrimitive!long.to!string;

			default:
				assert( 0 );

			}
		}

	private:
		BootstrapNamespace namespace_;
		Identifier identifier_;
		const size_t instanceSize_;
		const bool signed_;

}
