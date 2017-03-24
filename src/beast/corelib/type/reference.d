module beast.corelib.type.reference;

import beast.backend.common.codebuilder;
import beast.code.ast.expr.expression;
import beast.code.ast.node;
import beast.code.data.callable;
import beast.code.data.function_.bstpstcnonrt;
import beast.code.data.symbol;
import beast.code.data.type.class_;
import beast.code.data.type.type;
import beast.code.hwenv.hwenv;
import beast.code.memory.ptr;
import beast.corelib.type.toolkit;
import beast.code.data.function_.primmemrt;
import core.sync.rwmutex;

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
						BackendPrimitiveOperation.refRefCtor );

				// Dtor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( ), //
						BackendPrimitiveOperation.noopDtor );

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

}

final class ReferenceTypeManager {

	public:
		this( void delegate( Symbol ) sink, DataEntity parent ) {
		mutex_ = new ReadWriteMutex();

			symbol = new Symbol_BootstrapStaticNonRuntimeFunction( parent, ID!"Reference", //
					paramsBuilder.ctArg( coreLibrary.type.Type ).finish( ( MemoryPtr ptr ) { //
						return referenceTypeOf( ptr.readType( ) ).dataEntity; //
					} //
					 ) );

			sink( symbol );
		}

	public:
		Symbol_Type_Reference referenceTypeOf( Symbol_Type originalType ) {
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
