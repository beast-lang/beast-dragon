/// PRIMitive MEMber RunTime
module beast.code.data.function_.primmemrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.env;
import beast.code.data.var.local;
import beast.backend.common.primitiveop;

/// Primitive (compiler-defined, handled by backend) member (non-static) runtime (non-templated) function
final class Symbol_PrimitiveMemberRuntimeFunction : Symbol_RuntimeFunction {

	public:
		this( Identifier identifier, Symbol_Type parent, Symbol_Type returnType, ExpandedFunctionParameter[ ] parameters, BackendPrimitiveOperation op ) {
			staticData_ = new StaticData( this );

			identifier_ = identifier;
			parent_ = parent;
			returnType_ = returnType;
			parameters_ = parameters;
			op_ = op;
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
			// Do nothing
		}

	private:
		Identifier identifier_;
		Symbol_Type parent_;
		Symbol_Type returnType_;
		StaticData staticData_;
		ExpandedFunctionParameter[ ] parameters_;
		BackendPrimitiveOperation op_;

	protected:
		final class Data : super.Data {

			public:
				this( Symbol_PrimitiveMemberRuntimeFunction sym, DataEntity parentInstance ) {
					super( sym );
					assert( parentInstance.dataType is parent_ );

					sym_ = sym;
					parentInstance_ = parentInstance;
				}

			public:
				override DataEntity parent( ) {
					return parentInstance_;
				}

				override CallableMatch startCallMatch( AST_Node ast, bool isOnlyOverloadOption ) {
					return new Match( sym_, this, ast, isOnlyOverloadOption );
				}

			private:
				DataEntity parentInstance_;
				Symbol_PrimitiveMemberRuntimeFunction sym_;

		}

		final class StaticData : super.Data {

			public:
				this( Symbol_PrimitiveMemberRuntimeFunction sym ) {
					super( sym );
				}

			public:
				override DataEntity parent( ) {
					return parent_.dataEntity;
				}

				override CallableMatch startCallMatch( AST_Node ast, bool isOnlyOverloadOption ) {
					benforce( !isOnlyOverloadOption, E.needThis, "Need this for %s".format( this.tryGetIdentificationString ) );
					return new InvalidCallableMatch( this, "need this" );
				}

		}

		final class Match : super.Match {

			public:
				this( Symbol_PrimitiveMemberRuntimeFunction sym, Data sourceEntity, AST_Node ast, bool isOnlyOverloadOption ) {
					super( sym, sourceEntity, ast, isOnlyOverloadOption );

					parentInstance_ = sourceEntity.parentInstance_;
					sym_ = sym;
				}

			protected:
				override DataEntity _toDataEntity( ) {
					return new MatchData( sym_, this );
				}

			private:
				DataEntity parentInstance_;
				Symbol_PrimitiveMemberRuntimeFunction sym_;

		}

		final class MatchData : super.MatchData {

			public:
				this( Symbol_PrimitiveMemberRuntimeFunction sym, Match match ) {
					super( sym, match );

					parentInstance_ = match.parentInstance_;
					sym_ = sym;
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					const auto _gd = ErrorGuard( codeLocation );
					
					cb.build_primitiveOperation( sym_, op_, parentInstance_, arguments_ );
				}

			private:
				DataEntity parentInstance_;
				Symbol_PrimitiveMemberRuntimeFunction sym_;

		}

}
