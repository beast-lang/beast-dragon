module beast.code.data.function_.nrtparambuilder;

import beast.code.data.function_.toolkit;
import std.typetuple : TypeTuple;
import std.traits : RepresentationTypeTuple, Parameters;
import std.meta : aliasSeqOf;
import std.range : iota;
import std.functional : toDelegate;

abstract class CallMatchFactory( bool isMemberFunction_, SourceEntity_ ) {

	public:
		enum isMemberFunction = isMemberFunction_;
		alias SourceEntity = SourceEntity_;

	public:
		abstract CallableMatch startCallMatch( SourceEntity sourceEntity, AST_Node ast, bool canThrowErrors, MatchLevel matchLevel );

		abstract string[ ] argumentsIdentificationStrings( );

}

final class CallMatchFactoryImpl( bool isMemberFunction, SourceEntity, Builder_ ) : CallMatchFactory!( isMemberFunction, SourceEntity ) {

	public:
		alias Builder = Builder_;
		static string defaultIfFunc( Parameters!( Builder.IfFunc ) p ) {
			return null;
		}

	public:
		/// ifFunc is used as a post condition checking whether the overload applies. It returns null if yes or error message if not
		this( Builder builder, Builder.ObtainFunc obtainFunc, Builder.IfFunc ifFunc = toDelegate( &defaultIfFunc ) ) {
			builder_ = builder;
			obtainFunc_ = obtainFunc;
			ifFunc_ = ifFunc;
		}

	public:
		override CallableMatch startCallMatch( SourceEntity sourceEntity, AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
			return new Match!( typeof( this ) )( this, sourceEntity, ast, canThrowErrors, matchLevel );
		}

		override string[ ] argumentsIdentificationStrings( ) {
			string[ ] data;
			foreach ( i; aliasSeqOf!( iota( 1, Builder.BuilderCount ) ) )
				data ~= builder_.builder!i.identificationString;

			return data;
		}

	private:
		Builder builder_;
		Builder.ObtainFunc obtainFunc_;
		Builder.IfFunc ifFunc_;

}

final static class Match( Factory ) : SeriousCallableMatch {

	public:
		alias Builder = Factory.Builder;
		alias SourceEntity = Factory.SourceEntity;
		enum isMemberFunction = Factory.isMemberFunction;

	public:
		this( Factory factory, SourceEntity sourceEntity, AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
			super( sourceEntity, ast, canThrowErrors, factory.builder_.builder!( 0 ).initialMatchFlags_ | matchLevel );

			factory_ = factory;

			static if ( isMemberFunction )
				parentInstance_ = sourceEntity.parentInstance;
		}

	protected:
		override MatchLevel _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
			foreach ( i; aliasSeqOf!( iota( 1, Factory.Builder.BuilderCount ) ) ) {
				if ( currentFactoryItem_ == i ) {
					bool nextFactoryItem = true;

					MatchLevel result = factory_.builder_.builder!i.matchArgument( this, expression, entity, dataType, params_[ Builder.Builder!i.ParamsOffset .. Builder.Builder!i.ParamsOffset + Builder.Builder!i.Params.length ], nextFactoryItem );

					if ( nextFactoryItem )
						currentFactoryItem_++;

					return result;
				}
			}

			// If currentFactoryItem_ is outside builder bounds, that means that there are more arguments that parameters
			errorStr = "too many arguments";
			return MatchLevel.noMatch;
		}

		override MatchLevel _finish( ) {
			// Either we must have processed all factory items or the last one must be satisfied (this happens when the parameter is variadic)
			if ( currentFactoryItem_ != Factory.Builder.BuilderCount && !factory_.builder_.isSatisfied( params_[ Builder.ParamsOffset .. $ ] ) ) {
				errorStr = "not enough arguments";
				return MatchLevel.noMatch;
			}

			string ifResult;
			static if ( isMemberFunction )
				ifResult = factory_.ifFunc_( parentInstance_, params_ );
			else
				ifResult = factory_.ifFunc_( params_ );

			if ( ifResult ) {
				errorStr = ifResult;
				return MatchLevel.noMatch;
			}

			return MatchLevel.fullMatch;
		}

		override DataEntity _toDataEntity( ) {
			static if ( isMemberFunction )
				return factory_.obtainFunc_( ast, parentInstance_, params_ );
			else
				return factory_.obtainFunc_( ast, params_ );
		}

	private:
		size_t currentFactoryItem_ = 1; // Starting from 1 - first is Builer_Base which does nothing
		Factory factory_;
		Builder.ParamsTuple params_;
		static if ( isMemberFunction )
			DataEntity parentInstance_;

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
		enum isMemberFunction = Parent.isMemberFunction;
		alias SourceEntity = Parent.SourceEntity;
		enum BuilderCount = Parent.BuilderCount + 1;
		enum ParamsOffset = Parent.ParamsOffset + Parent.Params.length;
	}

	static if ( isMemberFunction ) {
		alias ObtainFunc = DataEntity delegate( AST_Node, DataEntity, ParamsTuple );
		alias IfFunc = string delegate( DataEntity, ParamsTuple );
	}
	else {
		alias ObtainFunc = DataEntity delegate( AST_Node, ParamsTuple );
		alias IfFunc = string delegate( ParamsTuple );
	}

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
		return Builder_ConstParameter!( typeof( this ) )( this, data.dataType, data.ctExec.keepValue );
	}

	/// Match single argument of any type
	auto auto_( )( ) {
		return Builder_Auto!( typeof( this ) )( this );
	}

	/// Matches anything (adds AST_Expression[] and DataEntity[] parameter to obtainFunc - AST_Expression[] for unparsed parameters, DataEntity[] for parsed ones)
	auto ast( )( ) {
		return Builder_AST!( typeof( this ) )( this );
	}

	CallMatchFactory!( isMemberFunction, SourceEntity ) finish( )( ObtainFunc obtainFunc ) {
		return new CallMatchFactoryImpl!( isMemberFunction, SourceEntity, typeof( this ) )( this, obtainFunc );
	}

	CallMatchFactory!( isMemberFunction, SourceEntity ) finishIf( )( IfFunc ifFunc, ObtainFunc obtainFunc ) {
		return new CallMatchFactoryImpl!( isMemberFunction, SourceEntity, typeof( this ) )( this, obtainFunc, ifFunc );
	}

	template Builder( size_t id ) {
		static if ( id == BuilderCount - 1 )
			alias Builder = typeof( this );
		else
			alias Builder = Parent.Builder!id;
	}

	auto ref builder( size_t id )( ) {
		static if ( id == BuilderCount - 1 )
			return this;
		else
			return parent.builder!id;
	}

	bool isSatisfied( ref Params params ) {
		return false;
	}

}

struct Builer_Base( bool isMemberFunction_, SourceEntity_ ) {
	alias Parent = void;
	enum isMemberFunction = isMemberFunction_;
	alias SourceEntity = SourceEntity_;
	mixin BuilderCommon;
	alias Params = TypeTuple!( );

	auto ref markAsFallback( ) {
		initialMatchFlags_ |= MatchLevel.fallback;
		return this;
	}

	private:
		MatchLevel initialMatchFlags_ = MatchLevel.fullMatch;
}

struct Builder_RuntimeParameter( Parent ) {
	mixin BuilderCommon;

	alias Params = TypeTuple!( DataEntity );

	MatchLevel matchArgument( SeriousCallableMatch match, AST_Expression expression, DataEntity entity, Symbol_Type dataType, ref Params params, ref bool nextFactoryItem ) {
		auto result = match.matchStandardArgument( expression, entity, dataType, type_ );
		if ( result == MatchLevel.noMatch )
			return MatchLevel.noMatch;

		params[ 0 ] = entity;
		return result;
	}

	string identificationString( ) {
		return type_.tryGetIdentificationString;
	}

	private:
		Symbol_Type type_;

}

struct Builder_CtimeParameter( Parent ) {
	mixin BuilderCommon;

	alias Params = TypeTuple!( MemoryPtr );

	MatchLevel matchArgument( SeriousCallableMatch match, AST_Expression expression, DataEntity entity, Symbol_Type dataType, ref Params params, ref bool nextFactoryItem ) {
		CTExecResult ctexec;

		auto result = match.matchCtimeArgument( expression, entity, dataType, type_, ctexec );
		if ( result == MatchLevel.noMatch )
			return MatchLevel.noMatch;

		params[ 0 ] = ctexec.keepValue;
		return result;
	}

	string identificationString( ) {
		return "@ctime %s".format( type_.tryGetIdentificationString );
	}

	private:
		Symbol_Type type_;

}

struct Builder_ConstParameter( Parent ) {
	mixin BuilderCommon;

	alias Params = TypeTuple!( );

	MatchLevel matchArgument( SeriousCallableMatch match, AST_Expression expression, DataEntity entity, Symbol_Type dataType, ref Params params, ref bool nextFactoryItem ) {
		auto result = match.matchConstValue( expression, entity, dataType, type_, value_ );
		if ( result == MatchLevel.noMatch )
			return MatchLevel.noMatch;

		return result;
	}

	string identificationString( ) {
		return "@ctime %s = %s".format( type_.tryGetIdentificationString, type_.valueIdentificationString( value_ ) );
	}

	private:
		Symbol_Type type_;
		MemoryPtr value_;

}

struct Builder_AST( Parent ) {
	mixin BuilderCommon;

	alias Params = TypeTuple!( AST_Expression[ ], DataEntity[ ] );

	MatchLevel matchArgument( SeriousCallableMatch match, AST_Expression expression, DataEntity entity, Symbol_Type dataType, ref Params params, ref bool nextFactoryItem ) {
		params[ 0 ] ~= expression;
		params[ 1 ] ~= entity;

		nextFactoryItem = false;
		return MatchLevel.fullMatch;
	}

	string identificationString( ) {
		return "...";
	}

	bool isSatisfied( ref Params params ) {
		return true;
	}

}

struct Builder_Auto( Parent ) {
	mixin BuilderCommon;

	alias Params = TypeTuple!( DataEntity );

	MatchLevel matchArgument( SeriousCallableMatch match, AST_Expression expression, DataEntity entity, Symbol_Type dataType, ref Params params, ref bool nextFactoryItem ) {
		auto result = match.matchAutoArgument( expression, entity, dataType );
		if ( result == MatchLevel.noMatch )
			return MatchLevel.noMatch;

		params[ 0 ] = entity;
		return result;
	}

	string identificationString( ) {
		return "@ctime %s".format( type_.tryGetIdentificationString );
	}

	private:
		Symbol_Type type_;

}
