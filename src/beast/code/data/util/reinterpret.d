module beast.code.data.util.reinterpret;

import beast.code.data.toolkit;
import beast.code.data.util.proxy;

/// Data entity that "reinterpret casts" source data entity into different datatype (no data change)
final class DataEntity_ReinterpretCast : ProxyDataEntity {

	public:
		this( DataEntity sourceEntity, Symbol_Type newType ) {
			super( sourceEntity );
			newType_ = newType;
		}

	public:
		override Symbol_Type dataType( ) {
			return newType_;
		}

	public:
		override string identification( ) {
			return "##reinterpretCast( %s )".format( newType_.identificationString );
		}

		override Hash outerHash( ) {
			return super.outerHash + newType_.outerHash;
		}

	private:
		Symbol_Type newType_;

}
