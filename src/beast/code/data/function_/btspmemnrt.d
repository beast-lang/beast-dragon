module beast.code.data.function_.bstpmemnrt;

import beast.code.data.function_.toolkit;
import beast.code.data.function_.nonrt;
import beast.code.data.function_.nrtparambuilder;

final class Symbol_BootstrapMemberNonRuntimeFunction : Symbol_NonRuntimeFunction {

	public:
		static auto paramsBuilder( ) {
			return Builer_Base!( true, Data )( );
		}

	public:
		this( DataEntity parent, Identifier id, CallMatchFactory!( true, Data ) matchFactory ) {
			parent_ = parent;
			id_ = id;
			matchFactory_ = matchFactory;

			staticData_ = new StaticData( this );
		}

	public:
		override DeclType declarationType( ) {
			return DeclType.staticFunction;
		}

		override Identifier identifier( ) {
			return id_;
		}

	public:
		override DataEntity dataEntity( DataEntity parentInstance = null ) {
			if ( parentInstance )
				return new Data( this, parentInstance );
			else
				return staticData_;
		}

	private:
		DataEntity parent_;
		Identifier id_;
		CallMatchFactory!( true, Data ) matchFactory_;
		DataEntity staticData_;

	protected:
		final static class Data : SymbolRelatedDataEntity {

			public:
				this( Symbol_BootstrapMemberNonRuntimeFunction sym, DataEntity parentInstance ) {
					super( sym );
					sym_ = sym;
					parentInstance_ = parentInstance;
				}

			public:
				override string identification( ) {
					return "%s( %s )".format( sym_.identifier.str, sym_.matchFactory_.argumentsIdentificationStrings.joiner( ", " ) );
				}

				override Symbol_Type dataType( ) {
					// TODO: better
					return coreLibrary.type.Void;
				}

				final override DataEntity parent( ) {
					return sym_.parent_;
				}

				final override bool isCtime( ) {
					return true;
				}

				final override bool isCallable( ) {
					return true;
				}

			public:
				DataEntity parentInstance( ) {
					return parentInstance_;
				}

			public:
				override CallableMatch startCallMatch( AST_Node ast, bool isOnlyOverloadOption ) {
					return sym_.matchFactory_.startCallMatch( this, ast, isOnlyOverloadOption );
				}

			protected:
				Symbol_BootstrapMemberNonRuntimeFunction sym_;
				DataEntity parentInstance_;

		}

		final static class StaticData : SymbolRelatedDataEntity {

			public:
				this( Symbol_BootstrapMemberNonRuntimeFunction sym ) {
					super( sym );
					sym_ = sym;
				}

			public:
				override string identification( ) {
					return "%s( %s )".format( sym_.identifier.str, sym_.matchFactory_.argumentsIdentificationStrings.joiner( ", " ) );
				}

				override Symbol_Type dataType( ) {
					// TODO: better
					return coreLibrary.type.Void;
				}

				final override DataEntity parent( ) {
					return sym_.parent_;
				}

				final override bool isCtime( ) {
					return true;
				}

				final override bool isCallable( ) {
					return true;
				}

			public:
				override CallableMatch startCallMatch( AST_Node ast, bool isOnlyOverloadOption ) {
					benforce( !isOnlyOverloadOption, E.needThis, "Need this for %s".format( this.tryGetIdentificationString ) );
					return new InvalidCallableMatch( this, "need this" );
				}

			private:
				Symbol_BootstrapMemberNonRuntimeFunction sym_;

		}

}
