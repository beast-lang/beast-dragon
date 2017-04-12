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
		this( DataEntity parent, Identifier id, CallMatchFactory!( false, Data ) matchFactory, bool staticCallOnly = false ) {
			parent_ = parent;
			id_ = id;
			matchFactory_ = matchFactory;
			staticCallOnly_ = staticCallOnly;
		}

	public:
		override DeclType declarationType( ) {
			return DeclType.staticFunction;
		}

		override Identifier identifier( ) {
			return id_;
		}

	public:
		override DataEntity dataEntity( MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null ) {
			return new Data( this, parentInstance, matchLevel );
		}

	private:
		DataEntity parent_;
		Identifier id_;
		CallMatchFactory!( false, Data ) matchFactory_;
		bool staticCallOnly_;

	protected:
		final static class Data : super.Data {

			public:
				this( Symbol_BootstrapStaticNonRuntimeFunction sym, DataEntity parentInstance, MatchLevel matchLevel ) {
					super( sym, matchLevel | MatchLevel.staticCall );
					sym_ = sym;
					parentInstance_ = parentInstance;
				}

			public:
				override string identification( ) {
					return "%s( %s )".format( sym_.identifier.str, sym_.matchFactory_.argumentsIdentificationStrings.joiner( ", " ) );
				}

				override Symbol_Type dataType( ) {
					// TODO: better
					return coreType.Void;
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
				override CallableMatch startCallMatch( AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
					if ( parentInstance_ is null || !sym_.staticCallOnly_ )
						return sym_.matchFactory_.startCallMatch( this, ast, canThrowErrors, matchLevel | this.matchLevel );
					else {
						//benforce( !canThrowErrors, E.staticCallOnly, "Function %s can only be called statically".format( this.tryGetIdentificationString ) );
						return new InvalidCallableMatch( this, "can only be called statically" );
					}
				}

			protected:
				Symbol_BootstrapStaticNonRuntimeFunction sym_;
				DataEntity parentInstance_;

		}

}
