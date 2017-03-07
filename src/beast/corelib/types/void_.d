module beast.corelib.types.void_;

import beast.corelib.types.toolkit;

final class Symbol_Type_Void : Symbol_StaticClassType {

	public:
		this( DataEntity parent ) {
			super( parent );

			namespace_ = new BootstrapNamespace( this );
			namespace_.initialize( null );
		}

	public:
		override Identifier identifier( ) {
			return Identifier.preobtained!"Void";
		}

		override size_t instanceSize( ) {
			return 0;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	private:
		BootstrapNamespace namespace_;

}
