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
						BackendPrimitiveOperation.zeroInitCtor );

				// Copy/assign ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( enm.xxctor.opAssign, this ), //
						BackendPrimitiveOperation.primitiveCopyCtor );

				// Ref ctor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap( enm.xxctor.opRefAssign, baseType ), //
						BackendPrimitiveOperation.refRefCtor );

				// Dtor
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", this, tp.Void, //
						ExpandedFunctionParameter.bootstrap(), //
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

Symbol_BootstrapStaticNonRuntimeFunction symbol_Template_Reference( DataEntity parent ) {
	ReadWriteMutex mtx = new ReadWriteMutex( );
	Symbol_Type_Reference[ Symbol_Type ] cache;

	Symbol_Type_Reference referenceTypeOf( Symbol_Type originalType ) {
		synchronized ( mtx.reader ) {
			if ( auto result = originalType in cache )
				return *result;
		}

		synchronized ( mtx.writer ) {
			// Check again, the type might have got added when switching mutexes
			if ( auto result = originalType in cache )
				return *result;

			auto result = new Symbol_Type_Reference( coreLibrary.type.Reference.dataEntity, originalType );
			result.initialize( );

			cache[ originalType ] = result;
			return result;
		}

		assert( 0 );
	}

	return new Symbol_BootstrapStaticNonRuntimeFunction( parent, ID!"Reference", //
			paramsBuilder.ctArg( coreLibrary.type.Type ).finish( ( MemoryPtr ptr ) { //
				return referenceTypeOf( ptr.readType( ) ).dataEntity; //
			} //
			 ) //
	 );
}
/*
final class Symbol_Template_Reference : Symbol_BootstrapStaticNonRuntimeFunction {

	public:
		this( DataEntity parent ) {
			super( parent );

			staticData_ = new Data( this );
			referencesMutex_ = new ReadWriteMutex( );
		}

	public:
		override Identifier identifier( ) {
			return ID!"Reference";
		}

		override DataEntity dataEntity( DataEntity parentInstance = null ) {
			return staticData_;
		}

	public:
		final override void buildDefinitionsCode( CodeBuilder cb ) {
			// TODO: this
		}

	public:
		final Symbol_Type_Reference referenceType( Symbol_Type originalType ) {
			synchronized ( referencesMutex_.reader ) {
				if ( auto result = originalType in referenceTypes_ )
					return *result;
			}

			synchronized ( referencesMutex_.writer ) {
				// Check again, the type might have got added when switching mutexes
				if ( auto result = originalType in referenceTypes_ )
					return *result;

				auto result = new Symbol_Type_Reference( dataEntity, originalType );
				referenceTypes_[ originalType ] = result;
				return result;
			}

			assert( 0 );
		}

	private:
		Data staticData_;
		ReadWriteMutex referencesMutex_;
		Symbol_Type_Reference[ Symbol_Type ] referenceTypes_;

	private:
		final static class Data : super.Data {

			public:
				this( Symbol_Template_Reference sym ) {
					super( sym );
					sym_ = sym;
				}

			public:
				override CallableMatch startCallMatch( AST_Node ast ) {
					return new Match( this, ast );
				}

			private:
				Symbol_Template_Reference sym_;

		}

		final static class Match : super.Match {

			public:
				this( Data sourceEntity, AST_Node ast ) {
					super( sourceEntity, ast );
					sym_ = sourceEntity.sym_;
				}

			protected:
				override MatchFlags _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
					switch ( argumentIndex_ ) {

					case 0: {
							MemoryPtr data;
							auto result = matchCtimeParameter( expression, entity, dataType, coreLibrary.type.Type, data );
							referencedType_ = data.readType( );
							return result;
						}

					default:
						errorStr = "parameter count mismatch";
						return MatchFlags.noMatch;

					}
				}

				override MatchFlags _finish( ) {
					if ( argumentIndex_ != 1 ) {
						errorStr = "parameter count mismatch";
						return MatchFlags.noMatch;
					}

					return MatchFlags.fullMatch;
				}

				override DataEntity _toDataEntity( ) {
					return sym_.referenceType( referencedType_ ).dataEntity;
				}

			private:
				Symbol_Type referencedType_;
				Symbol_Template_Reference sym_;

		}

}
*/
