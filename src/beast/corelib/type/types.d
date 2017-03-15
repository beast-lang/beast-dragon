module beast.corelib.type.types;

import beast.corelib.type.toolkit;
import beast.corelib.type.type;
import beast.util.decorator;

struct CoreLibrary_Types {
	/// ( instanceSize, defaultValue )
	alias bootstrapType = Decorator!( "corelib.types.bootstrap", size_t );
	alias enumType = Decorator!( "corelib.types.enum", string );

	public:
		@bootstrapType( 1 )
		Symbol_BootstrapStaticClass Bool;

		@bootstrapType( 0 )
		Symbol_BootstrapStaticClass Void;

		@bootstrapType( 4 )
		Symbol_BootstrapStaticClass Int;

		Symbol_Type_Type Type;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			sink( Type = new Symbol_Type_Type( parent ) );

			// Auto-initialize bootstrap types
			{
				import std.string : chomp;

				foreach ( memName; __traits( derivedMembers, typeof( this ) ) ) {
					foreach ( attr; __traits( getAttributes, __traits( getMember, this, memName ) ) ) {
						static if ( is( typeof( attr ) == bootstrapType ) ) {
							sink(  //
									__traits( getMember, this, memName ) = new Symbol_BootstrapStaticClass(  //
									parent, //
									memName.chomp( "_" ).Identifier, //
									attr[ 0 ] //
									 ) );

							break;
						}
					}
				}
			}
		}

		/// Second phase of initialization
		void initialize2( ) {
			import beast.corelib.type.bool_ : initialize_Bool;
			initialize_Bool( this );
		}

}
