/// PRIMitive MEMber RunTime
module beast.code.data.function_.primmemrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.env;
import beast.code.data.var.local;
import beast.backend.common.primitiveop;

/// Primitive (compiler-defined, handled by backend) member (non-static) runtime (non-templated) function
final class Symbol_PrimitiveMemberRuntimeFunction : Symbol_RuntimeFunction {

	public:
		// 0th param is this pointer
		alias CodeFunction = void delegate( CodeBuilder cb, DataScope scope_, DataEntity_LocalVariable[ ] parameters );

	public:
		this( string identifier, Symbol_Type parent, Symbol_Type returnType, ExpandedFunctionParameter[ ] parameters, BackendPrimitiveOperation op ) {
			identifier_ = Identifier( identifier );
			parent_ = parent;
			returnType_ = returnType;
			parameters_ = parameters;
			op_ = op;
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
					return new InvalidCallableMatch( this, "need this" );
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
					cb.build_primitiveOperation( scope_, op_, parentInstance_, arguments_ );
				}

			private:
				DataEntity parentInstance_;

		}

}
