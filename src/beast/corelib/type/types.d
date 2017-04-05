module beast.corelib.type.types;

import beast.corelib.type.toolkit;
import beast.corelib.type.type;
import beast.util.decorator;
import beast.corelib.type.reference;
import beast.code.data.function_.bstpstcnrt;
import beast.corelib.type.int_;
import beast.corelib.type.pointer;
import beast.code.hwenv.hwenv;

struct CoreLibrary_Types {
	/// ( instanceSize, defaultValue )
	alias bootstrapType = Decorator!( "corelib.types.bootstrap", size_t );
	alias enumType = Decorator!( "corelib.types.enum", string );

	public:
		@bootstrapType( 0 )
		Symbol_BootstrapStaticClass Void;

		@bootstrapType( 1 )
		Symbol_BootstrapStaticClass Bool;

	public:
		// TODO: Unsigned types
		// TODO: Type recasting
		@bootstrapType( 4 )
		Symbol_BootstrapStaticClass Int32;

		@bootstrapType( 8 )
		Symbol_BootstrapStaticClass Int64;

		Symbol_BootstrapStaticClass Size;

	public:
		Symbol_Type_Type Type;

		ReferenceTypeManager Reference;
		Symbol_Type_Pointer Pointer;

	public:
		void initialize( void delegate( Symbol ) sink, DataEntity parent ) {
			sink( Type = new Symbol_Type_Type( parent ) );
			sink( Pointer = new Symbol_Type_Pointer( parent ) );

			sink( new Symbol_BootstrapAlias( ID!"Int", ( matchLevel, inst ) => Int32.dataEntity( matchLevel ).Overloadset ) );

			// Auto-initialize bootstrap types
			{
				import std.string : chomp;

				foreach ( memName; __traits( derivedMembers, typeof( this ) ) ) {
					foreach ( attr; __traits( getAttributes, __traits( getMember, this, memName ) ) ) {
						static if ( is( typeof( attr ) == bootstrapType ) ) {
							auto mem = new Symbol_BootstrapStaticClass(  //
									parent, //
									memName.chomp( "_" ).Identifier, //
									attr[ 0 ] //
							 );

							__traits( getMember, this, memName ) = mem;

							sink( mem );
							break;
						}
					}
				}
			}

			Reference = new ReferenceTypeManager( sink, parent );

			// TODO: Dedicated type for Size
			switch ( hardwareEnvironment.pointerSize ) {

			case 4:
				Size = Int32;
				break;

			case 8:
				Size = Int64;
				break;

			default:
				assert( 0, "Unsupported pointer size" );

			}
		}

		/// Second phase of initialization
		void initialize2( ) {
			import beast.corelib.type.bool_ : initialize_Bool;

			Void.initialize( null );
			Type.initialize( );
			Pointer.initialize( );

			initialize_Int( Int32, this );
			initialize_Int( Int64, this );

			initialize_Bool( this );
		}

}
