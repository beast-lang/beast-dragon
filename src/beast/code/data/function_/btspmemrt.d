/// BootStraP MEMber RunTime
module beast.code.data.function_.btspmemrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.env;
import beast.code.data.var.local;

/// Bootstrap (compiler-defined) member (non-static) runtime (non-templated) function
final class Symbol_BootstrapMemberRuntimeFunction : Symbol_RuntimeFunction {

	public:
		// 0th param is this pointer
		alias CodeFunction = void delegate( CodeBuilder cb, DataEntity_LocalVariable[ ] parameters );

	public:
		this( string identifier, Symbol_Type parent, Symbol_Type returnType, ExpandedFunctionParameter[ ] parameters, CodeFunction codeFunction ) {
			staticData_ = new StaticData( this );

			identifier_ = Identifier( identifier );
			parent_ = parent;
			returnType_ = returnType;
			parameters_ = parameters;
			codeFunction_ = codeFunction;
		}

		override Identifier identifier( ) {
			return identifier_;
		}

		override Symbol_Type returnType( ) {
			return returnType_;
		}

		override ExpandedFunctionParameter[ ] parameters( ) {
			return parameters_;
		}

		override DeclType declarationType( ) {
			return DeclType.memberFunction;
		}

	public:
		override DataEntity dataEntity( DataEntity parentInstance = null ) {
			if ( !parentInstance )
				return staticData_;
			else
				return new Data( this, parentInstance );
		}

	protected:
		override void buildDefinitionsCode( CodeBuilder cb, StaticMemberMerger staticMemberMerger ) {
			with ( memoryManager.session ) {
				auto _s = scoped!RootDataScope( staticData_ );
				auto _sgd = _s.scopeGuard;

				cb.build_functionDefinition( this, ( cb ) { //
					DataEntity_LocalVariable[ ] paramEntities;

					{
						auto thisPtr = new DataEntity_ContextPointer( ID!"this", parent_ );
						_s.addLocalVariable( thisPtr );
						paramEntities ~= thisPtr;
					}

					foreach ( param; parameters ) {
						auto ent = new DataEntity_FunctionParameter( param );
						_s.addLocalVariable( ent );
						paramEntities ~= ent;
					}

					scope env = DeclarationEnvironment.newFunctionBody( );
					env.staticMembersParent = staticData_;
					env.staticMemberMerger = staticMemberMerger;

					codeFunction_( cb, paramEntities );
				} );

				_s.finish( );
			}
		}

	private:
		Identifier identifier_;
		Symbol_Type parent_;
		Symbol_Type returnType_;
		StaticData staticData_;
		ExpandedFunctionParameter[ ] parameters_;
		CodeFunction codeFunction_;

	protected:
		final static class Data : super.Data {

			public:
				this( Symbol_BootstrapMemberRuntimeFunction sym, DataEntity parentInstance ) {
					super( sym );
					assert( parentInstance.dataType is sym.parent_ );

					parentInstance_ = parentInstance;
					sym_ = sym;
				}

			public:
				override DataEntity parent( ) {
					return parentInstance_;
				}

				override CallableMatch startCallMatch( AST_Node ast ) {
					return new Match( sym_, this, ast );
				}

			private:
				DataEntity parentInstance_;
				Symbol_BootstrapMemberRuntimeFunction sym_;

		}

		final static class StaticData : super.Data {

			public:
				this( Symbol_BootstrapMemberRuntimeFunction sym ) {
					super( sym );
					sym_ = sym;
				}

			public:
				override DataEntity parent( ) {
					return sym_.parent_.dataEntity;
				}

				override CallableMatch startCallMatch( AST_Node ast ) {
					return new InvalidCallableMatch( this, "need this" );
				}

			private:
				Symbol_BootstrapMemberRuntimeFunction sym_;

		}

		final static class Match : super.Match {

			public:
				this( Symbol_BootstrapMemberRuntimeFunction sym, Data sourceEntity, AST_Node ast ) {
					super( sym, sourceEntity, ast );

					sym_ = sym;
					parentInstance_ = sourceEntity.parentInstance_;
				}

			protected:
				override DataEntity _toDataEntity( ) {
					return new MatchData( sym_, this );
				}

			private:
				DataEntity parentInstance_;
				Symbol_BootstrapMemberRuntimeFunction sym_;

		}

		final static class MatchData : super.MatchData {

			public:
				this( Symbol_BootstrapMemberRuntimeFunction sym, Match match ) {
					super( sym, match );
					sym_ = sym;
					parentInstance_ = match.parentInstance_;
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					cb.build_functionCall( sym_, parentInstance_, arguments_ );
				}

			private:
				DataEntity parentInstance_;
				Symbol_BootstrapMemberRuntimeFunction sym_;

		}

}
