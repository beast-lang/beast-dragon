module beast.corelib.type.type;

import beast.corelib.type.toolkit;
import beast.code.data.type.stcclass;
import beast.code.data.scope_.scope_;
import beast.code.data.overloadset;
import beast.code.data.type.type;

/// Type 'Type' -- typeof all classes etc.
/// The root of all good and evil in Beast.
/// Here be dragons
final class Symbol_Type_Type : Symbol_StaticClass {

	public:
		this( DataEntity parent ) {
			super( parent );

			namespace_ = new BootstrapNamespace( this );
			namespace_.initialize( null );
		}

	public:
		override Identifier identifier( ) {
			return ID!"Type";
		}

		override size_t instanceSize( ) {
			return size_t.sizeof;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	public:
		override Overloadset _resolveIdentifier_mid( Identifier id, DataScope scope_, DataEntity instance ) {
			//import std.stdio;
			if ( instance ) {
				Symbol_Type type = instance.ctExec_asType( scope_ );
				//writefln("Subtest for %s",type.identificationString);
				if ( auto result = type.resolveIdentifier( id, scope_, null ) )
					return result;
			}

			return Overloadset( );
		}

	private:
		BootstrapNamespace namespace_;

}
