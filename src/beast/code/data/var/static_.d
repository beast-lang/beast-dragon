module beast.code.data.var.static_;

import beast.code.data.toolkit;
import beast.code.data.var.variable;

/// User (programmer) defined variable
abstract class Symbol_StaticVariable : Symbol_Variable {

	protected:
		this( DataEntity parent ) {
			parent_ = parent;
			staticData_ = new Data;
		}

	public:
		final override DeclType declarationType( ) {
			return DeclType.staticVariable;
		}

	public:
		final override DataEntity dataEntity( DataEntity parentInstance = null ) {
			return staticData_;
		}

		abstract bool isCtime( );

		final DataEntity parent( ) {
			return parent_;
		}

	public:
		final override void buildDefinitionsCode( CodeBuilder cb ) {
			// No static variable definition - that information should be obtained from the memory manager
		}

	private:
		Data staticData_;
		DataEntity parent_;

	private:
		final class Data : SymbolRelatedDataEntity {

			public:
				this( ) {
					// Static variables are in global scope
					super( this.outer );
				}

			public:
				override Symbol_Type dataType( ) {
					return this.outer.dataType;
				}

				override bool isCtime( ) {
					return this.outer.isCtime;
				}

				override DataEntity parent( ) {
					return this.outer.parent_;
				}

			public:
				override void buildCode( CodeBuilder cb, DataScope scope_ ) {
					cb.build_memoryAccess( this.outer.memoryPtr );
				}

		}

}
