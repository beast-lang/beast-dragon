/// BootStraP MEMber RunTime
module beast.code.data.function_.btspmemrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.env;
import beast.code.data.var.local;

/// Bootstrap (compiler-defined) member (non-static) runtime (non-templated) function
final class Symbol_BootstrapMemberRuntimeFunction : Symbol_RuntimeFunction {

	public:
		// 0th param is this pointer
		alias CodeFunction = void delegate( CodeBuilder cb, DataScope scope_, DataEntity_LocalVariable[ ] parameters );

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
				cb.build_functionDefinition( this, ( cb ) { //
					auto scope_ = scoped!RootDataScope( staticData_ );

					DataEntity_LocalVariable[ ] paramEntities;

					{
						auto thisPtr = new DataEntity_ContextPointer( scope_, ID!"this", parent_ );
						scope_.addLocalVariable( thisPtr );
						paramEntities ~= thisPtr;
					}

					foreach ( param; parameters ) {
						auto ent = new DataEntity_FunctionParameter( scope_, param );
						scope_.addLocalVariable( ent );
						paramEntities ~= ent;
					}

					scope env = DeclarationEnvironment.newFunctionBody( );
					env.scope_ = scope_;
					env.staticMembersParent = staticData_;
					env.staticMemberMerger = staticMemberMerger;

					codeFunction_( cb, scope_, paramEntities );

					scope_.finish( );
				} );
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

				override CallableMatch startCallMatch( DataScope scope_, AST_Node ast ) {
					return new Match( sym_, scope_, this, ast );
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

				override CallableMatch startCallMatch( DataScope scope_, AST_Node ast ) {
					return new InvalidCallableMatch( this, "need this" );
				}

			private:
				Symbol_BootstrapMemberRuntimeFunction sym_;

		}

		final static class Match : super.Match {

			public:
				this( Symbol_BootstrapMemberRuntimeFunction sym, DataScope scope_, Data sourceEntity, AST_Node ast ) {
					super( sym, scope_, sourceEntity, ast );

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
				override void buildCode( CodeBuilder cb, DataScope scope_ ) {
					cb.build_functionCall( scope_, sym_, parentInstance_, arguments_ );
				}

			private:
				DataEntity parentInstance_;
				Symbol_BootstrapMemberRuntimeFunction sym_;

		}

}
