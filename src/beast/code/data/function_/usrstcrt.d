/// USeR StaTiC RunTime
module beast.code.data.function_.usrstcrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.function_;
import beast.code.decorationlist;
import beast.code.ast.decl.env;

final class Symbol_UserStaticRuntimeFunction : Symbol_RuntimeFunction {
	mixin TaskGuard!"returnTypeDeduction";
	mixin TaskGuard!"parameterExpanding";

	public:
		this( AST_FunctionDeclaration ast, DecorationList decorationList, FunctionDeclarationData data ) {
			staticData_ = new Data( this );

			ast_ = ast;
			decorationList_ = decorationList;
			parent_ = data.env.staticMembersParent;

			taskManager.issueJob( { enforceDone_returnTypeDeduction( ); } );
			taskManager.issueJob( { enforceDone_parameterExpanding( ); } );
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
			return DeclType.staticFunction;
		}

	public:
		override DataEntity dataEntity( DataEntity parentInstance = null ) {
			// TODO: MatchFlags
			return staticData_;
		}

	protected:
		override void buildDefinitionsCode( CodeBuilder cb, StaticMemberMerger staticMemberMerger ) {
			with ( memoryManager.session ) {
				auto _gd = ErrorGuard( ast );
				auto _s = scoped!RootDataScope( staticData_ );
				auto _sgd = _s.scopeGuard;

				cb.build_functionDefinition( this, ( cb ) { //
					foreach ( param; parameters ) {
						if ( param.identifier )
							_s.addLocalVariable( new DataEntity_FunctionParameter( param ) );
					}

					scope env = DeclarationEnvironment.newFunctionBody( );
					env.staticMembersParent = parent_;
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
		DataEntity parent_;

	protected:
		final void execute_returnTypeDeduction( ) {
			// If the return type is auto, the type is inferred in the buildDefinitionsCode function (which is run from the codeProcessing)
			if ( ast_.returnType.isAutoExpression )
				enforceDone_codeProcessing( );
			else
				returnTypeWIP_ = ast_.returnType.standaloneCtExec( coreLibrary.type.Type, parent_ ).readType( );
		}

		final void execute_parameterExpanding( ) {
			with ( memoryManager.session ) {
				auto _s = scoped!RootDataScope( parent_ );
				auto _sgd = _s.scopeGuard;

				foreach ( expr; ast_.parameterList.items )
					expandedParametersWIP_ ~= ExpandedFunctionParameter.process( expr );

				_s.finish( );
				// Do not cleanup the scope - it can and will be used
			}
		}

	protected:
		final class Data : super.Data {

			public:
				this( Symbol_UserStaticRuntimeFunction sym ) {
					assert( this.outer );
					super( sym );

					sym_ = sym;
				}

			public:
				override DataEntity parent( ) {
					return sym_.parent_;
				}

			private:
				Symbol_UserStaticRuntimeFunction sym_;

		}

}
