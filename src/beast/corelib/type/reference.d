module beast.corelib.type.reference;

import beast.backend.common.codebuilder;
import beast.code.ast.expr.expression;
import beast.code.ast.node;
import beast.code.data.callable;
import beast.code.data.function_.bstpmemnrt;
import beast.code.data.function_.bstpstcnrt;
import beast.code.data.function_.primmemrt;
import beast.code.data.overloadset;
import beast.code.data.symbol;
import beast.code.data.type.class_;
import beast.code.data.type.type;
import beast.code.data.util.proxy;
import beast.code.hwenv.hwenv;
import beast.code.memory.ptr;
import beast.corelib.type.toolkit;
import beast.util.hash;
import core.sync.rwmutex;
import beast.code.data.callmatchset;

final class Symbol_Type_Reference : Symbol_Class {

	public:
		this( DataEntity parent, Symbol_Type baseType ) {
			id_ = Identifier( "%s_ref".format( baseType.identifier.str ) );

			// Identifier must be available
			super( );

			parent_ = parent;
			baseType_ = baseType;

			staticData_ = new Data( this );

			namespace_ = new BootstrapNamespace( this );

			// Initialize members
			{
				Symbol[ ] mem;
				auto tp = &coreLibrary.type;

				// Implicit ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( ), //
						BackendPrimitiveOperation.memZero );

				// Copy/assign ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( enm.xxctor.opAssign, this ), //
						BackendPrimitiveOperation.memCpy );

				// Ref ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( enm.xxctor.opRefAssign, baseType ), //
						BackendPrimitiveOperation.storeAddr );

				// Dtor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( ), //
						BackendPrimitiveOperation.noopDtor );

				// Fallback for #operator
				mem ~= new Symbol_BootstrapMemberNonRuntimeFunction( dataEntity, ID!"#operator", //
						Symbol_BootstrapMemberNonRuntimeFunction.paramsBuilder( ).markAsFallback( ).matchesAnything( ).finish( ( AST_Node ast, DataEntity instance, AST_Expression[ ] argAsts, DataEntity[ ] argEnts ) { //
							assert( argAsts.length == argEnts.length );

							auto this_ = this;
							auto base = baseType_;
							auto proxy = new ProxyData( instance, base );
							auto overloadset = proxy.resolveIdentifier( ID!"#operator" );
							auto set = CallMatchSet( overloadset, ast, true );
							//auto set = CallMatchSet( new ProxyData( instance, baseType_ ).resolveIdentifier( ID!"#operator" ), ast, true );

							foreach ( i; 0 .. argAsts.length ) {
								if ( auto ent = argEnts[ i ] )
									set.arg( ent );
								else if ( auto arg = argAsts[ i ] )
									set.arg( arg );
								else
									assert( 0 );
							}

							return set.finish( );
						} ) ); //

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

		override DataEntity dataEntity( DataEntity parentInstance = null ) {
			return staticData_;
		}

	public:
		override bool isReference( ) {
			return true;
		}

	protected:
		override Overloadset _resolveIdentifier_mid( Identifier id, DataEntity instance ) {
			// We shadow referenced type namespace
			auto proxyData = new ProxyData( instance, baseType_ );

			return baseType_.resolveIdentifier_noTypeFallback( id, proxyData );
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
				this( Symbol_Type_Reference sym ) {
					super( sym );
					sym_ = sym;
				}

			public:
				override DataEntity parent( ) {
					return sym_.parent_;
				}

				override string identificationString( ) {
					return "%s?".format( sym_.baseType_.tryGetIdentificationString );
				}

			private:
				Symbol_Type_Reference sym_;

		}

		final static class ProxyData : ProxyDataEntity {

			public:
				this( DataEntity sourceEntity, Symbol_Type baseType ) {
					super( sourceEntity );
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
					// Although loadAddr returns something, we pass Void as a return type,
					// because build_primitiveOperation would allocate a variable for the return value (which we don't want to)
					cb.build_primitiveOperation( coreLibrary.type.Void, BackendPrimitiveOperation.loadAddr, sourceEntity_, null );
				}

			protected:
				override Overloadset _resolveIdentifier_main( Identifier id ) {
					return Overloadset();
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
			benforce( !originalType.isReference, E.referenceOfReference, "Cannot have reference of reference (%s)".format( originalType.identificationString ) );

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
