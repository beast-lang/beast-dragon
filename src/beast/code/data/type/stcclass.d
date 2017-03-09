module beast.code.data.type.stcclass;

import beast.code.data.toolkit;
import beast.code.data.type.class_;

abstract class Symbol_StaticClass : Symbol_Class {

	public:
		this( DataEntity parent ) {
			staticData_ = new Data;
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
		final class Data : super.Data {

			public:
				override DataEntity parent( ) {
					return parent_;
				}

		}

}
