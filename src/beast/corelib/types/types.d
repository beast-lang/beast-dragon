module beast.corelib.types.types;

import beast.corelib.types.toolkit;
import beast.corelib.types.type;
import beast.util.decorator;
import beast.corelib.types.btsp;
import beast.code.data.function_.btspmemrt;

struct CoreLibrary_Types {
	/// ( instanceSize )
	alias bootstrapType = Decorator!( "corelib.types.bootstrap", size_t );

	public:
		@bootstrapType( 1 )
		Symbol_CorelibBoostrapType Bool;

		@bootstrapType( 0 )
		Symbol_CorelibBoostrapType Void;

		@bootstrapType( 4 )
		Symbol_CorelibBoostrapType Int;

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
									__traits( getMember, this, memName ) = new Symbol_CorelibBoostrapType(  //
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
			{
				Symbol[ ] sym;
				sym ~= new Symbol_BootstrapMemberRuntimeFunction( "#operator", Bool, Bool, //
						ExpandedFunctionParameter.bootstrap( coreLibrary.constants.operator_or, Bool ), //
						( cb, scope_, params ) { //
							// Do nothing
						} );

				Bool.initialize( sym );
			}
		}

}
