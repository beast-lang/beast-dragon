module beast.corelib.types.btsp;

import beast.corelib.types.toolkit;

final class Symbol_CorelibBoostrapType : Symbol_StaticClassType {

	public:
		this( DataEntity parent, Identifier identifier, size_t instanceSize ) {
			// This code must be before super call, as super constructor calls identifier
			identifier_ = identifier;
			instanceSize_ = instanceSize;

			super( parent );
			assert( identifier );

			namespace_ = new BootstrapNamespace( this );
		}

		void initialize( Symbol[ ] members ) {
			namespace_.initialize( members );
		}

	public:
		override Identifier identifier( ) {
			return identifier_;
		}

		override size_t instanceSize( ) {
			return instanceSize_;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	private:
		BootstrapNamespace namespace_;
		Identifier identifier_;
		size_t instanceSize_;

}
