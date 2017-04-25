module beast.code.data.function_.usrstcnrt;

import beast.code.data.function_.toolkit;
import beast.code.data.function_.nonrt;
import beast.code.ast.decl.function_;
import beast.code.data.function_.paramlist;
import beast.code.decorationlist;
import beast.code.ast.expr.vardecl;

final class Symbol_UserStaticNonRuntimeFunction : Symbol_NonRuntimeFunction {

	public:
		this( AST_FunctionDeclaration ast, DecorationList decorationList, FunctionDeclarationData data, FunctionParameterList paramList ) {
			ast_ = ast;
			decorationList_ = decorationList;
			parent_ = data.env.staticMembersParent;
			paramList_ = paramList;

			staticData_ = new Data( this, null, MatchLevel.fullMatch );
		}

	public:
		override DeclType declarationType( ) {
			return DeclType.memberFunction;
		}

		override Identifier identifier( ) {
			return ast_.identifier;
		}

	public:
		override DataEntity dataEntity( MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null ) {
			if ( parentInstance || matchLevel != MatchLevel.fullMatch )
				return new Data( this, parentInstance, matchLevel );
			else
				return staticData_;
		}

	private:
		DataEntity parent_;
		AST_FunctionDeclaration ast_;
		FunctionParameterList paramList_;
		DecorationList decorationList_;
		Data staticData_;

	protected:
		final static class Data : super.Data {

			public:
				this( Symbol_UserStaticNonRuntimeFunction sym, DataEntity parentInstance, MatchLevel matchLevel ) {
					super( sym, matchLevel );
					sym_ = sym;
					parentInstance_ = parentInstance;
				}

			public:
				override string identification( ) {
					// TODO: better identification?
					return "%s( ... )".format( sym_.identifier.str );
				}

				override string identificationString_noPrefix( ) {
					return "%s.%s".format( sym_.parent_.identificationString, identification );
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
				DataEntity parentInstance( ) {
					return parentInstance_;
				}

			public:
				override CallableMatch startCallMatch( AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
					return new Match( sym_, this, null, ast, canThrowErrors, this.matchLevel | matchLevel );
				}

			protected:
				Symbol_UserStaticNonRuntimeFunction sym_;
				DataEntity parentInstance_;

		}

		static class Match : SeriousCallableMatch {

			public:
				this( Symbol_UserStaticNonRuntimeFunction sym, DataEntity sourceEntity, DataEntity parentInstance, AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
					super( sourceEntity, ast, canThrowErrors, matchLevel );
					sym_ = sym;
					sourceEntity_ = sourceEntity;
					parentInstance_ = parentInstance;
				}

			protected:
				override MatchLevel _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
					auto _sgd = scope_.scopeGuard( false );
					MatchLevel result = MatchLevel.fullMatch;

					// TODO: variadic arguments, default values
					if ( argumentIndex_ >= sym_.paramList_.parameterCount ) {
						errorStr = "too many arguments";
						return MatchLevel.noMatch;
					}

					auto paramData = sym_.paramList_.paramData( argumentIndex_ );

					// Declaration -> standard parameter
					if ( AST_VariableDeclarationExpression decl = paramData.ast.isVariableDeclaration ) {

					}
					// otherwise constval parameter
					else {
						//result |= matchConstValue( expression, entity, dataType, param.dataType, param.constValue );
					}

				/*	if ( param.constValue )

					else
						result |= matchStandardArgument( expression, entity, dataType, param.dataType );*/

					if ( result == MatchLevel.noMatch )
						return MatchLevel.noMatch;

					arguments_ ~= entity;

					return result;
				}

				override MatchLevel _finish( ) {
					if ( argumentIndex_ != sym_.paramList_.parameterCount ) {
						errorStr = "not enough arguments";
						return MatchLevel.noMatch;
					}

					return MatchLevel.fullMatch | super._finish( );
				}

				override DataEntity _toDataEntity( ) {
					assert( 0 );
				}

			protected:
				Symbol_UserStaticNonRuntimeFunction sym_;
				DataEntity[ ] arguments_;
				DataEntity sourceEntity_, parentInstance_;

		}

}
