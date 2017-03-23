module beast.code.data.var.static_;

import beast.code.data.toolkit;
import beast.code.data.var.variable;

/// User (programmer) defined variable
abstract class Symbol_StaticVariable : Symbol_Variable {

	protected:
		this( DataEntity parent ) {
			parent_ = parent;
			staticData_ = new Data( this );
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

	private:
		Data staticData_;
		DataEntity parent_;

	private:
		final static class Data : SymbolRelatedDataEntity {

			public:
				this( Symbol_StaticVariable sym ) {
					// Static variables are in global scope
					super( sym );
					sym_ = sym;
				}

			public:
				override Symbol_Type dataType( ) {
					return sym_.dataType;
				}

				override bool isCtime( ) {
					return sym_.isCtime;
				}

				override DataEntity parent( ) {
					return sym_.parent_;
				}

				override string identificationString( ) {
					return "%s %s".format( sym_.dataType.tryGetIdentificationString, super.identificationString );
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					auto _gd = ErrorGuard( this );
					
					cb.build_memoryAccess( sym_.memoryPtr );
				}

			private:
				Symbol_StaticVariable sym_;

		}

}
