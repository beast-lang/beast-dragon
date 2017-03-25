module beast.code.data.function_.bstpstcnrt;

import beast.code.data.function_.toolkit;
import beast.code.data.function_.nonrt;
import beast.code.data.function_.nrtparambuilder;

final class Symbol_BootstrapStaticNonRuntimeFunction : Symbol_NonRuntimeFunction {

	public:
		static auto paramsBuilder( ) {
			return Builer_Base!( false, Data )( );
		}

	public:
		this( DataEntity parent, Identifier id, CallMatchFactory!( false, Data ) matchFactory ) {
			parent_ = parent;
			id_ = id;
			matchFactory_ = matchFactory;

			staticData_ = new Data( this );
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
			return staticData_;
		}

	private:
		DataEntity parent_;
		Identifier id_;
		CallMatchFactory!( false, Data ) matchFactory_;
		DataEntity staticData_;

	protected:
		final static class Data : SymbolRelatedDataEntity {

			public:
				this( Symbol_BootstrapStaticNonRuntimeFunction sym ) {
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
					return sym_.matchFactory_.startCallMatch( this, ast, isOnlyOverloadOption );
				}

			protected:
				Symbol_BootstrapStaticNonRuntimeFunction sym_;

		}

}
