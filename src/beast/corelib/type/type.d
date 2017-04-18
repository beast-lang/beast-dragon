module beast.corelib.type.type;

import beast.corelib.type.toolkit;
import beast.code.data.type.stcclass;
import beast.util.uidgen;

/// Type 'Type' -- typeof all classes etc.
/// The root of all good and evil in Beast.
/// Here be dragons
final class Symbol_Type_Type : Symbol_StaticClass {

	public:
		this( DataEntity parent ) {
			super( parent );

			namespace_ = new BootstrapNamespace( this );
		}

		override void initialize( ) {
			super.initialize( );

			Symbol[ ] mem;

			mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreType.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					( cb, inst, args ) { //
						// Initialize to void
						cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, coreType.Void.dataEntity );
					} );

			mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreType.Void, //
					ExpandedFunctionParameter.bootstrap( coreEnum.xxctor.refAssign, this ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 1 ] );
					} );

			mem ~= Symbol_PrimitiveMemberRuntimeFunction.newNoopDtor( this );

			mem ~= opRefAssign = new Symbol_PrimitiveMemberRuntimeFunction( ID!"#refAssign", this, coreType.Void, //
					ExpandedFunctionParameter.bootstrap( this ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 0 ] );
					} );

			namespace_.initialize( mem );
		}

	public:
		override Identifier identifier( ) {
			return ID!"Type";
		}

		override size_t instanceSize( ) {
			return UIDGenerator.I.sizeof;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	public:
		override string valueIdentificationString( MemoryPtr value ) {
			return value.readType.identificationString;
		}

	public:
		Symbol_PrimitiveMemberRuntimeFunction opRefAssign;

	protected:
		override Overloadset _resolveIdentifier_pre( Identifier id, DataEntity instance, MatchLevel matchLevel ) {
			// opRefAssign has priority over mirroring referenced type
			if( id == ID!"#refAssign" )
				return opRefAssign.dataEntity( matchLevel, instance ).Overloadset;

			if ( instance ) {
				Symbol_Type type = instance.standaloneCtExec_asType( );

				if ( auto result = type.tryResolveIdentifier( id, null, matchLevel ) )
					return result;
			}

			return Overloadset( );
		}

	private:
		BootstrapNamespace namespace_;

}
