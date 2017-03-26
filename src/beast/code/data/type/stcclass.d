module beast.code.data.type.stcclass;

import beast.code.data.toolkit;
import beast.code.data.type.class_;

abstract class Symbol_StaticClass : Symbol_Class {

	public:
		this( DataEntity parent ) {
			staticData_ = new Data( this, MatchLevel.fullMatch );
			parent_ = parent;
		}

	public:
		final override DeclType declarationType( ) {
			return DeclType.staticClass;
		}

	public:
		final override DataEntity dataEntity( MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null ) {
			if ( matchLevel != MatchLevel.fullMatch )
				return new Data( this, matchLevel );
			else
				return staticData_;
		}

	protected:
		DataEntity staticData_;
		DataEntity parent_;

	private:
		final static class Data : super.Data {

			public:
				this( Symbol_StaticClass sym, MatchLevel matchLevel ) {
					super( sym, matchLevel );

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
