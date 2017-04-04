/// USeR MEMber RunTime
module beast.code.data.function_.usrmemrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.function_;
import beast.code.decorationlist;
import beast.code.ast.decl.env;

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
			with ( memoryManager.session ) {
				auto thisPtr = new DataEntity_ContextPointer( ID!"this", parent_, cb.isCtime );

				auto _gd = ErrorGuard( codeLocation );
				auto _s = new RootDataScope( thisPtr );
				auto _sgd = _s.scopeGuard;

				_s.addEntity( thisPtr );

				cb.build_functionDefinition( this, ( cb ) { //
					foreach ( param; parameters ) {
						if ( param.identifier )
							_s.addLocalVariable( new DataEntity_FunctionParameter( param ) );
					}

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
						returnTypeWIP_ = env.functionReturnType ? env.functionReturnType : coreLibrary.type.Void;

					// returnTypeWIP_ is definitely accessible now (we called returnType before in this function or eventually set the value ourselves)
					if ( returnTypeWIP_ is coreLibrary.type.Void )
						cb.build_return( null );

				} );

				_s.finish( );
			}
		}

	private:
		ExpandedFunctionParameter[ ] expandedParametersWIP_;
		Symbol_Type returnTypeWIP_;

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
				returnTypeWIP_ = ast_.returnType.standaloneCtExec( coreLibrary.type.Type, parent_.dataEntity ).readType( );
		}

		final void execute_parameterExpanding( ) {
			with ( memoryManager.session ) {
				auto _s = new RootDataScope( parent_.dataEntity );
				auto _sgd = _s.scopeGuard;

				foreach ( i, expr; ast_.parameterList.items )
					expandedParametersWIP_ ~= ExpandedFunctionParameter.process( expr, i );

				_s.finish( );
				// Do not cleanup the scope - it can and will be used
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
				override DataEntity parent( ) {
					return parentInstance_ ? parentInstance_ : sym_.parent_.dataEntity;
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
