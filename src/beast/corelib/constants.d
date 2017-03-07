module beast.corelib.constants;

import beast.corelib.toolkit;
import beast.code.data.var.btspconst;
import beast.util.decorator;

struct CoreLibrary_Constants {

	public:
		/// ( type, value )
		alias constant = Decorator!( "corelib.constants.constant", string, ulong );

	public:
		@constant( "Bool", 0x01 )
		Symbol_BoostrapConstant true_;

		@constant( "Bool", 0x00 )
		Symbol_BoostrapConstant false_;

	public:
		@constant( "Int", 1 )
		Symbol_BoostrapConstant operator_or;

		@constant( "Int", 2 )
		Symbol_BoostrapConstant operator_orRight;

		@constant( "Int", 3 )
		Symbol_BoostrapConstant operator_call;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			import std.string : chomp;

			auto types = coreLibrary.types;

			foreach ( memName; __traits( derivedMembers, typeof( this ) ) ) {
				foreach ( attr; __traits( getAttributes, __traits( getMember, this, memName ) ) ) {
					static if ( is( typeof( attr ) == constant ) ) {
						sink(  //
								__traits( getMember, this, memName ) = new Symbol_BoostrapConstant(  //
								parent, //
								memName.chomp( "_" ).Identifier, //
								__traits( getMember, types, attr[ 0 ] ), //
								literal!( attr[ 1 ] ) ) //
						 );

						break;
					}
				}
			}
		}

	private:
		template literal( alias val ) {
			static immutable ulong data = val;
			static immutable literal = &data;
		}

}
