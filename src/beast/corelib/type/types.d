module beast.corelib.type.types;

import beast.corelib.type.toolkit;
import beast.corelib.type.type;
import beast.util.decorator;
import beast.code.data.function_.btspmemrt;
import beast.code.data.function_.primmemrt;
import beast.code.data.type.btspenum;
import beast.backend.common.primitiveop;

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
			{
				Symbol[ ] sym;

				// Implicit constructor
				sym ~= new Symbol_PrimitiveMemberRuntimeFunction( "#ctor", Bool, Void, //
						ExpandedFunctionParameter.bootstrap( ), //
						BackendPrimitiveOperation.boolCtor //
						 );

				sym ~= new Symbol_BootstrapMemberRuntimeFunction( "#operator", Bool, Bool, //
						ExpandedFunctionParameter.bootstrap( coreLibrary.enum_.operator.binOr, Bool ), //
						( cb, scope_, params ) { //
							// Do nothing
						} );

				Bool.initialize( sym );
			}
		}

}
