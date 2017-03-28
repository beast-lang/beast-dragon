module beast.corelib.const_.enums;

import beast.corelib.toolkit;
import beast.code.data.var.btspconst;
import beast.util.decorator;
import beast.code.data.type.btspenum;

struct CoreLibrary_Enums {

	private:
		alias C = Symbol_BoostrapConstant;
		alias E = Symbol_BootstrapEnum;

	public:
		/// ( baseClass )
		alias enum_ = Decorator!( "corelib.enum.enum_", string );
		alias standardEnumItems = Decorator!( "corelib.enum.standardEnumItems", string );

	public:
		@enum_( "Int" )
		E Operator;

		struct OperatorItems {
			C binOr, binOrR, binAnd, binAndR;
			C binPlus, binPlusR, binMinus, binMinusR;

			C funcCall;

			C preNot;
			C suffRef, suffNot;

			C assign, refAssign;
		}

		@standardEnumItems( "Operator" )
		OperatorItems operator;

	public:
		@enum_( "Int" )
		E XXCtor;

		struct XXCtorItems {
			C opAssign; /// Assign constructor: #ctor( #Ctor.opAssign, val ) -> Var x = y
			C opRefAssign; /// Ref assign constructor: #ctor( #Ctor.opRefAssign, val ) -> Var x := y
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
						auto enum_ = new Symbol_BootstrapEnum(  //
								parent, //
								memName.chomp( "_" ).replaceAll( ctRegex!"XX", "#" ).Identifier, //
								__traits( getMember, types, attr[ 0 ] ), //
								 );
						__traits( getMember, this, memName ) = enum_;

						sink( enum_ );

						break;
					}
					else static if ( is( typeof( attr ) == standardEnumItems ) ) {
						InitRecord rec;
						rec.baseClass = __traits( getMember, this, attr[ 0 ] );
						ulong i = 0;

						foreach ( subMemName; __traits( derivedMembers, typeof( __traits( getMember, typeof( this ), memName ) ) ) ) {
							rec.items ~= (  //
									__traits( getMember, __traits( getMember, this, memName ), subMemName ) = new Symbol_BoostrapConstant(  //
									parent, //
									subMemName.chomp( "_" ).Identifier, //
									rec.baseClass, //
									i //
									 ) //
							 );

							i++;
						}

						initList_ ~= rec;
					}
				}
			}
		}

		void initialize2( ) {
			foreach ( rec; initList_ )
				rec.baseClass.initialize( rec.items );

			initList_ = null;
		}

	private:
		struct InitRecord {
			Symbol_BootstrapEnum baseClass;
			Symbol[ ] items;
		}

		InitRecord[ ] initList_;

}
