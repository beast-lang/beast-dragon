module beast.code.data.function_.bstpstcnonrt;

import beast.code.data.function_.toolkit;
import beast.code.data.function_.nonrt;
import std.typetuple : TypeTuple;
import std.traits : RepresentationTypeTuple;
import std.meta : aliasSeqOf;
import std.range : iota;

final class Symbol_BootstrapStaticNonRuntimeFunction : Symbol_NonRuntimeFunction {

	public:
		this( DataEntity parent, Identifier id, CallMatchFactory matchFactory ) {
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
		CallMatchFactory matchFactory_;
		DataEntity staticData_;

	protected:
		final static class Data : SymbolRelatedDataEntity {

			public:
				this( Symbol_BootstrapStaticNonRuntimeFunction sym ) {
					super( sym );
					sym_ = sym;
				}

			public:
				final override Symbol_Type dataType( ) {
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
				override CallableMatch startCallMatch( AST_Node ast ) {
					return sym_.matchFactory_.startCallMatch( this, ast );
				}

			protected:
				Symbol_BootstrapStaticNonRuntimeFunction sym_;

		}

}

auto paramsBuilder( ) {
	return Builer_Base( );
}

private {
	abstract class CallMatchFactory {

		public:
			abstract CallableMatch startCallMatch( DataEntity sourceEntity, AST_Node ast );

	}

	final class CallMatchFactoryImpl( Builder_ ) : CallMatchFactory {

		public:
			alias Builder = Builder_;

		public:
			this( Builder builder, Builder.ObtainFunc obtainFunc ) {
				builder_ = builder;
				obtainFunc_ = obtainFunc;
			}

		public:
			override CallableMatch startCallMatch( DataEntity sourceEntity, AST_Node ast ) {
				return new Match!( typeof( this ) )( this, sourceEntity, ast );
			}

		private:
			Builder builder_;
			Builder.ObtainFunc obtainFunc_;

	}

	final static class Match( Factory ) : SeriousCallableMatch {

		public:
			alias Builder = Factory.Builder;

		public:
			this( Factory factory, DataEntity sourceEntity, AST_Node ast ) {
				super( sourceEntity, ast );
				factory_ = factory;
			}

		protected:
			override MatchFlags _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
				foreach ( i; aliasSeqOf!( iota( 1, Factory.Builder.BuilderCount ) ) ) {
					if ( currentFactoryItem_ == i ) {
						bool nextFactoryItem = true;

						MatchFlags result = factory_.builder_.builder!i.matchArgument( this, expression, entity, dataType, params_[ Builder.Builder!i.ParamsOffset .. Builder.Builder!i.ParamsOffset + Builder.Builder!i.Params.length ], nextFactoryItem );

						if ( nextFactoryItem )
							currentFactoryItem_++;

						return result;
					}
				}

				// If currentFactoryItem_ is outside builder bounds, that means that there are more arguments that parameters
				errorStr = "too many arguments";
				return MatchFlags.noMatch;
			}

			override MatchFlags _finish( ) {
				// Either we must have processed all factory items or the last one must be satisfied (this happens when the parameter is variadic)
				if ( currentFactoryItem_ != Factory.Builder.BuilderCount && !factory_.builder_.isSatisfied( params_[ Builder.ParamsOffset .. $ ] ) ) {
					errorStr = "not enough arguments";
					return MatchFlags.noMatch;
				}

				return MatchFlags.fullMatch;
			}

			override DataEntity _toDataEntity( ) {
				return factory_.obtainFunc_( params_ );
			}

		private:
			size_t currentFactoryItem_ = 1; // Starting from 1 - first is Builer_Base which does nothing
			Factory factory_;
			Builder.ParamsTuple params_;

	}

	mixin template BuilderCommon( ) {
		static if ( is( Parent == void ) ) {
			alias ParamsTuple = Params;
			enum BuilderCount = 1;
			enum ParamsOffset = 0;
		}
		else {
			Parent parent;
			alias ParamsTuple = TypeTuple!( Parent.ParamsTuple, Params );
			enum BuilderCount = Parent.BuilderCount + 1;
			enum ParamsOffset = Parent.ParamsOffset + Parent.Params.length;
		}

		alias ObtainFunc = DataEntity delegate( ParamsTuple );

		/// Match single runtime parameter of type type (adds DataEntity parameter to obtainFunc)
		auto rtArg( )( Symbol_Type type ) {
			return Builder_RuntimeParameter!( typeof( this ) )( this, type );
		}

		/// Match single ctime parameter of type type (adds MemoryPtr parameter to obtainFunc)
		auto ctArg( )( Symbol_Type type ) {
			return Builder_CtimeParameter!( typeof( this ) )( this, type );
		}

		/// Match single const-value parameter of type type and value value (doesn't add any parameters to obtainFunc)
		auto constArg( )( Symbol_Type type, MemoryPtr value ) {
			return Builder_ConstParameter!( typeof( this ) )( this, type, value );
		}

		/// Match single const-value parameter of value data (doesn't add any parameters to obtainFunc)
		auto constArg( )( DataEntity data ) {
			return Builder_ConstParameter!( typeof( this ) )( this, data.dataType, data.ctExec );
		}

		/// Match single const-value parameter of value data (doesn't add any parameters to obtainFunc)
		auto constArg( )( Symbol sym ) {
			auto data = sym.dataEntity;
			return Builder_ConstParameter!( typeof( this ) )( this, data.dataType, data.ctExec );
		}

		CallMatchFactory finish( )( ObtainFunc obtainFunc ) {
			return new CallMatchFactoryImpl!( typeof( this ) )( this, obtainFunc );
		}

		template Builder( size_t id ) {
			static if ( id == BuilderCount - 1 )
				alias Builder = typeof( this );
			else
				alias Builder = Parent.Builder!id;
		}

		auto ref builder( size_t id )( ) {
			static if ( id >= BuilderCount )
				return parent.builder!id;
			else
				return this;
		}

		bool isSatisfied( ref Params params ) {
			return false;
		}

	}

	struct Builer_Base {
		alias Parent = void;
		mixin BuilderCommon;

		alias Params = TypeTuple!( );
	}

	struct Builder_RuntimeParameter( Parent ) {
		mixin BuilderCommon;

		alias Params = TypeTuple!( DataEntity );

		Symbol_Type type;

		CallableMatch.MatchFlags matchArgument( SeriousCallableMatch match, AST_Expression expression, DataEntity entity, Symbol_Type dataType, ref Params params, ref bool nextFactoryItem ) {
			auto result = match.matchStandardArgument( expression, entity, dataType, type );
			if ( result == CallableMatch.MatchFlags.noMatch )
				return CallableMatch.MatchFlags.noMatch;

			params[ 0 ] = entity;
			return result;
		}

	}

	struct Builder_CtimeParameter( Parent ) {
		mixin BuilderCommon;

		alias Params = TypeTuple!( MemoryPtr );

		Symbol_Type type;

		CallableMatch.MatchFlags matchArgument( SeriousCallableMatch match, AST_Expression expression, DataEntity entity, Symbol_Type dataType, ref Params params, ref bool nextFactoryItem ) {
			MemoryPtr value;

			auto result = match.matchCtimeArgument( expression, entity, dataType, type, value );
			if ( result == CallableMatch.MatchFlags.noMatch )
				return CallableMatch.MatchFlags.noMatch;

			params[ 0 ] = value;
			return result;
		}

	}

	struct Builder_ConstParameter( Parent ) {
		mixin BuilderCommon;

		alias Params = TypeTuple!( );

		Symbol_Type type;
		MemoryPtr value;

		CallableMatch.MatchFlags matchArgument( SeriousCallableMatch match, AST_Expression expression, DataEntity entity, Symbol_Type dataType, ref Params params, ref bool nextFactoryItem ) {
			auto result = match.matchConstValue( expression, entity, dataType, type, value );
			if ( result == CallableMatch.MatchFlags.noMatch )
				return CallableMatch.MatchFlags.noMatch;

			return result;
		}

	}
}
