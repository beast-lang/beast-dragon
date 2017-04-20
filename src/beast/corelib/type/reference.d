module beast.corelib.type.reference;

import beast.backend.common.codebuilder;
import beast.corelib.type.toolkit;
import beast.util.hash;
import core.sync.rwmutex;
import beast.code.hwenv.hwenv;
import beast.code.data.util.deref;
import beast.code.data.util.direct;

final class Symbol_Type_Reference : Symbol_StaticClass {

	public:
		this( DataEntity parent, Symbol_Type baseType ) {
			id_ = Identifier( "%s_ref".format( baseType.identifier.str ) );

			// Identifier must be available
			super( parent );

			parent_ = parent;
			baseType_ = baseType;

			staticData_ = new Data( this, MatchLevel.fullMatch );

			namespace_ = new BootstrapNamespace( this );

			// Initialize members
			{
				Symbol[ ] mem;

				// Implicit constructor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreType.Void, //
						ExpandedFunctionParameter.bootstrap( ), //
						( cb, inst, args ) { //
							cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, inst );
							cb.build_primitiveOperation( BackendPrimitiveOperation.memZero, inst );
						} );

				// Copy ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreType.Void, //
						ExpandedFunctionParameter.bootstrap( this ), //
						( cb, inst, args ) { //
							cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, inst );
							cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 0 ] );
						} );

				// Ref copy ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreType.Void, //
						ExpandedFunctionParameter.bootstrap( enm.xxctor.refAssign, this ), //
						( cb, inst, args ) { //
							cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, inst );
							cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 1 ] );
						} );

				// Ref ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, coreType.Void, //
						ExpandedFunctionParameter.bootstrap( enm.xxctor.refAssign, baseType ), //
						( cb, inst, args ) { //
							// arg0 is #Ctor.refAssign!
							cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, inst );
							cb.build_primitiveOperation( BackendPrimitiveOperation.getAddr, inst, args[ 1 ] );
						} );

				// Dtor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", this, coreType.Void, //
						ExpandedFunctionParameter.bootstrap( ), //
						( cb, inst, args ) { //
							cb.build_primitiveOperation( BackendPrimitiveOperation.unmarkPtr, inst );
							cb.build_primitiveOperation( BackendPrimitiveOperation.noopDtor, inst );
						} );

				// Reference assign refa := refb
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#refAssign", this, coreType.Void, //
						ExpandedFunctionParameter.bootstrap( this ), //
						( cb, inst, args ) { //
							// arg0 is #Ctor.refAssign!
							cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 0 ] );
						} );

				// Reference assign refa := b
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#refAssign", this, coreType.Void, //
						ExpandedFunctionParameter.bootstrap( baseType_ ), //
						( cb, inst, args ) { //
							// arg0 is #Ctor.refAssign!
							cb.build_primitiveOperation( BackendPrimitiveOperation.getAddr, inst, args[ 0 ] );
						} );

				// Implicit cast to base type
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#implicitCast", this, baseType_, //
						ExpandedFunctionParameter.bootstrap( baseType_.dataEntity ), //
						( cb, inst, args ) => cb.build_dereference( &inst.buildCode ) //
						 );

				// Implicit cast to pointer
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#implicitCast", this, coreType.Pointer, //
						ExpandedFunctionParameter.bootstrap( coreType.Pointer.dataEntity ), //
						( cb, inst, args ) { //
							// Result is this entity, just with a different type (but that is not saved)
							inst.buildCode( cb );
						} );

				// .isNull
				mem ~= new Symbol_PropertyAlias( new Symbol_PrimitiveMemberRuntimeFunction( ID!"isNull", this, coreType.Bool, //
						ExpandedFunctionParameter.bootstrap( ), //
						( cb, inst, args ) { //
							coreType.Pointer.opBinary_equals.dataEntity( MatchLevel.fullMatch, inst.reinterpret( coreType.Pointer ) ).resolveCall( null, true, coreEnum.operator.binEq.dataEntity, coreEnum.null_.dataEntity ).buildCode( cb );
						} ) );

				// Alias #baseType
				mem ~= new Symbol_BootstrapAlias( ID!"#baseType", ( matchLevel, parentInstance ) => baseType_.dataEntity( matchLevel ).Overloadset );

				// #data for acessing all the referenced data members
				mem ~= new Symbol_BootstrapAlias( ID!"#data", //
						( matchLevel, inst ) => ( inst ? inst.dereference( baseType_ ) : baseType_.dataEntity( matchLevel ) ).Overloadset );

				// #reference for acessing only the REFERENCE data members (useful when you need to call #ctor or so)
				/*mem ~= new Symbol_BootstrapAlias( ID!"#reference", //
						( matchLevel, inst ) => new DataEntity_DirectProxy( inst ? inst.dereference( baseType_ ) : baseType_.dataEntity( matchLevel ) ).Overloadset );*/

				namespace_.initialize( mem );
			}
		}

	public:
		override Identifier identifier( ) {
			return id_;
		}

		override size_t instanceSize( ) {
			return hardwareEnvironment.pointerSize;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

		override DataEntity dataEntity( MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null ) {
			if ( matchLevel != MatchLevel.fullMatch )
				return new Data( this, matchLevel );
			else
				return staticData_;
		}

	public:
		override Symbol_Type_Reference isReferenceType( ) {
			return this;
		}

		Symbol_Type baseType( ) {
			return baseType_;
		}

	protected:
		override Overloadset _resolveIdentifier_mid( Identifier id, DataEntity instance, MatchLevel matchLevel ) {
			// We shadow referenced type namespace
			return baseType_.tryResolveIdentifier( id, instance ? new DataEntity_DereferenceProxy( instance, baseType_ ) : null, matchLevel );
		}

	private:
		Symbol_Type baseType_;
		BootstrapNamespace namespace_;
		DataEntity parent_;
		Identifier id_;

	private:
		final static class Data : super.Data {

			public:
				this( Symbol_Type_Reference sym, MatchLevel matchLevel ) {
					super( sym, matchLevel );
					sym_ = sym;
				}

			public:
				override string identificationString_noPrefix( ) {
					return "%s?".format( sym_.baseType_.tryGetIdentificationString );
				}

			private:
				Symbol_Type_Reference sym_;

		}

}

final class ReferenceTypeManager {

	public:
		this( void delegate( Symbol ) sink, DataEntity parent ) {
			mutex_ = new ReadWriteMutex( );

			symbol = new Symbol_BootstrapStaticNonRuntimeFunction( parent, ID!"Reference", //
					Symbol_BootstrapStaticNonRuntimeFunction.paramsBuilder.ctArg( coreType.Type ).finish( ( ast, MemoryPtr ptr ) { //
						return referenceTypeOf( ptr.readType( ) ).dataEntity; //
					} //
					 ) );

			sink( symbol );
		}

	public:
		Symbol_Type_Reference referenceTypeOf( Symbol_Type originalType ) {
			benforce( !originalType.isReferenceType, E.referenceOfReference, "Cannot have reference of reference (%s)".format( originalType.identificationString ) );

			synchronized ( mutex_.reader ) {
				if ( auto result = originalType in cache_ )
					return *result;
			}

			synchronized ( mutex_.writer ) {
				// Check again, the type might have got added when switching mutexes
				if ( auto result = originalType in cache_ )
					return *result;

				auto result = new Symbol_Type_Reference( symbol.dataEntity, originalType );
				result.initialize( );

				cache_[ originalType ] = result;
				return result;
			}

			assert( 0 );
		}

	public:
		Symbol_BootstrapStaticNonRuntimeFunction symbol;

	private:
		ReadWriteMutex mutex_;
		Symbol_Type_Reference[ Symbol_Type ] cache_;

}
