module beast.corelib.constants;

import beast.corelib.toolkit;
import beast.code.data.var.boostrapconst;

struct CoreLibrary_Constants {

	public:
		Symbol_BoostrapConstant true_;
		Symbol_BoostrapConstant false_;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			sink( true_ = new Symbol_BoostrapConstant( parent, "true".Identifier, coreLibrary.types.Bool, literal!0x01 ) );
			sink( false_ = new Symbol_BoostrapConstant( parent, "false".Identifier, coreLibrary.types.Bool, literal!0x00 ) );
		}

	private:
		template literal( alias val ) {
			static immutable typeof( val ) data = val;
			static immutable literal = &data;
		}

}
