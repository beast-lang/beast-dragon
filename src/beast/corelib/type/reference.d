module beast.corelib.type.reference;

import beast.code.data.alias_.btsp;
import beast.code.data.function_.bstpstcnrt;
import beast.code.data.function_.primmemrt;
import beast.code.data.toolkit;
import beast.code.data.type.class_;
import beast.code.data.type.type;
import beast.code.data.util.proxy;
import beast.code.hwenv.hwenv;
import beast.corelib.type.toolkit;
import core.sync.rwmutex;

final class Symbol_Type_Reference : Symbol_Class {

	public:
		this( DataEntity parent, Symbol_Type baseType ) {
			id_ = Identifier( "%s_ref".format( baseType.identifier.str ) );

			// Identifier must be available
			super( );

			parent_ = parent;
			baseType_ = baseType;

			staticData_ = new Data( this, MatchLevel.fullMatch );

			namespace_ = new BootstrapNamespace( this );

			// Initialize members
			{
				Symbol[ ] mem;
				auto tp = &coreLibrary.type;

				mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCtor( this ); // Implicit constructor
				mem ~= Symbol_PrimitiveMemberRuntimeFunction.newPrimitiveCopyCtor( this ); // Copy constructor
				mem ~= Symbol_PrimitiveMemberRuntimeFunction.newNoopDtor( this ); // Destructor

				// Ref ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( enm.xxctor.opRefAssign, baseType ), //
						( cb, inst, args ) { //
							// arg0 is #Ctor.opRefAssign!
							cb.build_primitiveOperation( BackendPrimitiveOperation.getAddr, inst, args[ 1 ] );
						} );

				// Reference assign refa := refb
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#operator", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( enm.operator.refAssign, this ), //
						( cb, inst, args ) { //
							// arg0 is #Ctor.opRefAssign!
							cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 1 ] );
						} );

				// Reference assign refa := b
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#operator", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( enm.operator.refAssign, baseType_ ), //
						( cb, inst, args ) { //
							// arg0 is #Ctor.opRefAssign!
							cb.build_primitiveOperation( BackendPrimitiveOperation.getAddr, inst, args[ 1 ] );
						} );

				// Implicit cast to base type
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#implicitCast", this, baseType_, //
						ExpandedFunctionParameter.bootstrap( baseType_.dataEntity ), //
						( cb, inst, args ) { //
							cb.build_primitiveOperation( BackendPrimitiveOperation.dereference, inst );
						} );

				// Alias for #operator
				mem ~= new Symbol_BootstrapAlias( ID!"#operator", ( matchLevel, inst ) { //
					return ( inst ? new ProxyData( inst, baseType_ ) : baseType_.dataEntity( matchLevel ) ).resolveIdentifier( ID!"#operator", matchLevel | MatchLevel.alias_ );
				} );

				// Alias #baseType
				mem ~= new Symbol_BootstrapAlias( ID!"#baseType", ( matchLevel, parentInstance ) { //
					return baseType_.dataEntity( matchLevel ).Overloadset;
				} );

				namespace_.initialize( mem );
			}
		}

	public:
		override Identifier identifier( ) {
			return id_;
		}

		override DeclType declarationType( ) {
			return DeclType.staticClass;
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
		override bool isReferenceType( ) {
			return true;
		}

	protected:
		override Overloadset _resolveIdentifier_mid( Identifier id, DataEntity instance, MatchLevel matchLevel ) {
			// We shadow referenced type namespace
			return baseType_.resolveIdentifier( id, new ProxyData( instance, baseType_ ), matchLevel );
		}

	private:
		Data staticData_;
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
				override DataEntity parent( ) {
					return sym_.parent_;
				}

				override string identificationString_noPrefix( ) {
					return "%s?".format( sym_.baseType_.tryGetIdentificationString );
				}

			private:
				Symbol_Type_Reference sym_;

		}

		final static class ProxyData : ProxyDataEntity {

			public:
				this( DataEntity sourceEntity, Symbol_Type baseType ) {
					super( sourceEntity, MatchLevel.fullMatch );
					baseType_ = baseType;
				}

			public:
				override Symbol_Type dataType( ) {
					return baseType_;
				}

			public:
				override string identification( ) {
					return "%s.##dereference".format( super.identification );
				}

				override Hash outerHash( ) {
					return super.outerHash + baseType_.outerHash;
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					cb.build_primitiveOperation( BackendPrimitiveOperation.dereference, sourceEntity_ );
				}

			protected:
				override Overloadset _resolveIdentifier_main( Identifier id, MatchLevel matchLevel ) {
					// We're overriding this because ProxyDataEntity would redirect this into sourceEntity
					return Overloadset( );
				}

			private:
				Symbol_Type baseType_;

		}

}

final class ReferenceTypeManager {

	public:
		this( void delegate( Symbol ) sink, DataEntity parent ) {
			mutex_ = new ReadWriteMutex( );

			symbol = new Symbol_BootstrapStaticNonRuntimeFunction( parent, ID!"Reference", //
					Symbol_BootstrapStaticNonRuntimeFunction.paramsBuilder.ctArg( coreLibrary.type.Type ).finish( ( ast, MemoryPtr ptr ) { //
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
