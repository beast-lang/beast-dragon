/// BootStraP MEMber RunTime
module beast.code.data.function_.btspmemrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.env;

/// Bootstrap (compiler-defined) member (non-static) runtime (non-templated) function
final class Symbol_BootstrapMemberRuntimeFunction : Symbol_RuntimeFunction {

	public:
		alias CodeFunction = void delegate( CodeBuilder cb, DataScope scope_, DataEntity_FunctionParameter[ ] parameters );

	public:
		this( string identifier, Symbol_Type parent, Symbol_Type returnType, ExpandedFunctionParameter[ ] parameters, CodeFunction codeFunction ) {
			identifier_ = Identifier( identifier );
			parent_ = parent;
			returnType_ = returnType;
			parameters_ = parameters;
			codeFunction_ = codeFunction;

			staticData_ = new StaticData( );
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
				return new Data( parentInstance );
		}

		override void buildDefinitionsCode( CodeBuilder cb ) {
			with ( memoryManager.session ) {
				cb.build_functionDefinition( this, ( cb ) { //
					scope scope_ = new RootDataScope( staticData_ );

					DataEntity_FunctionParameter[ ] paramEntities;
					foreach ( param; parameters ) {
						auto ent = new DataEntity_FunctionParameter( scope_, param );
						scope_.addLocalVariable( ent );
						paramEntities ~= ent;
					}

					scope env = DeclarationEnvironment.newFunctionBody( );
					env.scope_ = scope_;
					env.staticMembersParent = dataEntity;

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
		final class Data : super.Data {

			public:
				this( DataEntity parentInstance ) {
					assert( parentInstance.dataType is parent_ );

					parentInstance_ = parentInstance;
				}

			public:
				override DataEntity parent( ) {
					return parentInstance_;
				}

				override CallableMatch startCallMatch( DataScope scope_, AST_Node ast ) {
					return new Match( scope_, this, ast );
				}

			private:
				DataEntity parentInstance_;

		}

		final class StaticData : super.Data {

			public:
				override DataEntity parent( ) {
					return parent_.dataEntity;
				}

				override CallableMatch startCallMatch( DataScope scope_, AST_Node ast ) {
					return new InvalidCallableMatch( this );
				}

		}

		final class Match : super.Match {

			public:
				this( DataScope scope_, Data sourceEntity, AST_Node ast ) {
					super( scope_, sourceEntity, ast );

					parentInstance_ = sourceEntity.parentInstance_;
				}

			protected:
				override DataEntity _toDataEntity( ) {
					return new MatchData( this );
				}

			private:
				DataEntity parentInstance_;

		}

		final class MatchData : super.MatchData {

			public:
				this( Match match ) {
					super( match );
					parentInstance_ = match.parentInstance_;
				}

			public:
				override void buildCode( CodeBuilder cb, DataScope scope_ ) {
					cb.build_functionCall( scope_, this.outer, parentInstance_, arguments_ );
				}

			private:
				DataEntity parentInstance_;

		}

}
