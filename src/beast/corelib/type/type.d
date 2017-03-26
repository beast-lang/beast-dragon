module beast.corelib.type.type;

import beast.corelib.type.toolkit;
import beast.code.data.toolkit;
import beast.code.data.type.stcclass;

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
		override string valueIdentificationString( MemoryPtr value ) {
			return value.readType.identificationString;
		}

	protected:
		override Overloadset _resolveIdentifier_pre( Identifier id, DataEntity instance, MatchLevel matchLevel ) {
			if ( instance ) {
				Symbol_Type type = instance.ctExec_asType( );

				if ( auto result = type.resolveIdentifier( id, null, matchLevel ) )
					return result;
			}

			return Overloadset( );
		}

	private:
		BootstrapNamespace namespace_;

}
