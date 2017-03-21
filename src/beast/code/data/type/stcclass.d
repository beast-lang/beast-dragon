module beast.code.data.type.stcclass;

import beast.code.data.toolkit;
import beast.code.data.type.class_;

abstract class Symbol_StaticClass : Symbol_Class {

	public:
		this( DataEntity parent ) {
			staticData_ = new Data( this );
			parent_ = parent;
		}

	public:
		final override DeclType declarationType( ) {
			return DeclType.staticClass;
		}

	public:
		final override DataEntity dataEntity( DataEntity parentInstance = null ) {
			return staticData_;
		}

	protected:
		DataEntity staticData_;
		DataEntity parent_;

	private:
		final static class Data : super.Data {

			public:
				this( Symbol_StaticClass sym ) {
					super( sym );

					sym_ = sym;
				}

			public:
				override DataEntity parent( ) {
					return sym_.parent_;
				}

			private:
				Symbol_StaticClass sym_;

		}

}
