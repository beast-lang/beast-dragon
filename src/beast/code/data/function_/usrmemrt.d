/// USeR MEMber RunTime
module beast.code.data.function_.usrmemrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.function_;
import beast.code.decorationlist;
import beast.code.ast.decl.env;
import beast.code.data.scope_.blurry;

final class Symbol_UserMemberRuntimeFunction : Symbol_RuntimeFunction {
	mixin TaskGuard!"returnTypeDeduction";
	mixin TaskGuard!"parameterExpanding";

	public:
		this( AST_FunctionDeclaration ast, DecorationList decorationList, FunctionDeclarationData data ) {
			staticData_ = new Data( this, MatchLevel.fullMatch, null );

			ast_ = ast;
			decorationList_ = decorationList;
			parent_ = data.env.parentType;

			taskManager.delayedIssueJob( { enforceDone_returnTypeDeduction( ); } );
			taskManager.delayedIssueJob( { enforceDone_parameterExpanding( ); } );

			decorationList_.enforceAllResolved( ); // TODO: move somewhere else eventually
		}

		override Identifier identifier( ) {
			return ast_.identifier;
		}

		override Symbol_Type returnType( ) {
			enforceDone_returnTypeDeduction( );
			return returnTypeWIP_;
		}

		override Symbol_Type contextType( ) {
			return parent_;
		}

		override ExpandedFunctionParameter[ ] parameters( ) {
			enforceDone_parameterExpanding( );
			return expandedParametersWIP_;
		}

		override AST_Node ast( ) {
			return ast_;
		}

		override DeclType declarationType( ) {
			return DeclType.memberFunction;
		}

	public:
		override DataEntity dataEntity( MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null ) {
			if ( matchLevel != MatchLevel.fullMatch || parentInstance )
				return new Data( this, matchLevel, parentInstance );
			else
				return staticData_;
		}

	protected:
		override void buildDefinitionsCode( CodeBuilder cb, StaticMemberMerger staticMemberMerger ) {
			assert( !cb.isCtime );

			enforceDone_parameterExpanding( );

			// We open the new subscope as blurry, because multiple buildDefinitionsCode calls might be used the paramsScopeWIP_
			auto _sgd = new BlurryDataScope( paramsScopeWIP_ ).scopeGuard;
			auto _gd = ErrorGuard( codeLocation );

			cb.build_functionDefinition( this, ( cb ) { //
				scope env = DeclarationEnvironment.newFunctionBody( );
				env.staticMembersParent = parent_.dataEntity;
				env.staticMemberMerger = staticMemberMerger;

				if ( !ast_.returnType.isAutoExpression )
					env.functionReturnType = returnType;

				ast_.body_.buildStatementCode( env, cb );

				/*
						If the return type is auto and the staticMemberMerger is not finished (meaning this definition building is the 'main' codeProcessing one),
						we deduce a return type from the first encountered return statement (which sets env.functionReturnType if it was null previously)
					*/
				if ( ast_.returnType.isAutoExpression && !staticMemberMerger.isFinished )
					returnTypeWIP_ = env.functionReturnType ? env.functionReturnType : coreType.Void;

				// returnTypeWIP_ is definitely accessible now (we called returnType before in this function or eventually set the value ourselves)
				if ( returnTypeWIP_ is coreType.Void )
					cb.build_return( null );

			} ).inSession( SessionPolicy.watchCtChanges );
		}

	private:
		ExpandedFunctionParameter[ ] expandedParametersWIP_;
		Symbol_Type returnTypeWIP_;
		RootDataScope paramsScopeWIP_;

	private:
		AST_FunctionDeclaration ast_;
		DecorationList decorationList_;
		Data staticData_;
		Symbol_Type parent_;

	protected:
		final void execute_returnTypeDeduction( ) {
			// If the return type is auto, the type is inferred in the buildDefinitionsCode function (which is run from the codeProcessing)
			if ( ast_.returnType.isAutoExpression )
				enforceDone_codeProcessing( );
			else
				returnTypeWIP_ = ast_.returnType.ctExec_asType.inRootDataScope( parent_.dataEntity ).inStandaloneSession;
		}

		final void execute_parameterExpanding( ) {
			with ( memoryManager.session( SessionPolicy.doNotWatchCtChanges ) ) {
				auto thisPtr = new DataEntity_ContextPointer( ID!"this", parent_, false );

				paramsScopeWIP_ = new RootDataScope( thisPtr );
				debug paramsScopeWIP_.allowMultiThreadAccess = true;

				auto _sgd = paramsScopeWIP_.scopeGuard;

				paramsScopeWIP_.addEntity( thisPtr );

				foreach ( i, expr; ast_.parameterList.items )
					expandedParametersWIP_ ~= ExpandedFunctionParameter.process( expr, i );
			}
		}

	protected:
		final class Data : super.Data {

			public:
				this( Symbol_UserMemberRuntimeFunction sym, MatchLevel matchLevel, DataEntity parentInstance ) {
					assert( this.outer );
					super( sym, matchLevel | MatchLevel.staticCall );

					sym_ = sym;
					parentInstance_ = parentInstance;
				}

			public:
				final override DataEntity parent( ) {
					return sym_.parent_.dataEntity;
				}

				override CallableMatch startCallMatch( AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
					if ( parentInstance_ )
						return new Match( sym_, this, parentInstance_, ast, canThrowErrors, matchLevel | this.matchLevel );
					else {
						benforce( !canThrowErrors, E.needThis, "Need this for %s".format( this.tryGetIdentificationString ) );
						return new InvalidCallableMatch( this, "need this" );
					}
				}

			private:
				Symbol_UserMemberRuntimeFunction sym_;
				DataEntity parentInstance_;

		}

}
