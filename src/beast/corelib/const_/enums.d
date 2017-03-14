module beast.corelib.const_.enums;

import beast.corelib.toolkit;
import beast.code.data.var.btspconst;
import beast.util.decorator;
import beast.code.data.type.btspenum;

struct CoreLibrary_Enums {

	public:
		/// ( baseClass )
		alias enum_ = Decorator!( "corelib.enum.enum_", string );
		alias standardEnumItems = Decorator!( "corelib.enum.standardEnumItems", string );

	public:
		@enum_( "Int" )
		Symbol_BootstrapEnum Operator;

		struct OperatorItems {
			Symbol_BoostrapConstant binOr, binOrR;
			Symbol_BoostrapConstant andOr, andOrR;
			Symbol_BoostrapConstant funcCall;
		}

		@standardEnumItems( "Operator" )
		OperatorItems operator;

	public:
		@enum_( "Int" )
		Symbol_BootstrapEnum XXCtor;

		struct XXCtorItems {
			Symbol_BoostrapConstant copy;
			Symbol_BoostrapConstant opAssign, opRefAssign;
		}

		@standardEnumItems( "XXCtor" )
		XXCtorItems xxctor;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			import std.string : chomp;
			import std.regex : ctRegex, replaceAll;

			auto types = coreLibrary.type;

			foreach ( memName; __traits( derivedMembers, typeof( this ) ) ) {
				foreach ( attr; __traits( getAttributes, __traits( getMember, this, memName ) ) ) {
					static if ( is( typeof( attr ) == enum_ ) ) {
						sink(  //
								__traits( getMember, this, memName ) = new Symbol_BootstrapEnum(  //
								parent, //
								memName.chomp( "_" ).replaceAll( ctRegex!"XX", "#" ).Identifier, //
								__traits( getMember, types, attr[ 0 ] ), //
								 ) //
						 );

						break;
					}
					else static if ( is( typeof( attr ) == standardEnumItems ) ) {
						auto baseClass = __traits( getMember, this, attr[ 0 ] );
						ulong i = 0;

						Symbol[ ] initList;

						foreach ( subMemName; __traits( derivedMembers, typeof( __traits( getMember, typeof( this ), memName ) ) ) ) {
							initList ~= (  //
									__traits( getMember, __traits( getMember, this, memName ), subMemName ) = new Symbol_BoostrapConstant(  //
									parent, //
									subMemName.chomp( "_" ).Identifier, //
									baseClass, //
									i //
									 ) //
							 );

							i++;
						}

						baseClass.initialize( initList );
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
