module beast.code.data.type.btspenum;

import beast.code.data.toolkit;
import beast.code.data.codenamespace.namespace;
import beast.code.data.codenamespace.bootstrap;
import beast.code.data.type.enum_;
import beast.code.data.type.stcclass;

final class Symbol_BootstrapEnum : Symbol_Enum {

	public:
		this( DataEntity parent, Identifier identifier, Symbol_StaticClass baseClass ) {
			// This code must be before super call, as super constructor calls identifier
			identifier_ = identifier;

			super( parent, baseClass );
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
			return baseClass_.instanceSize;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	private:
		BootstrapNamespace namespace_;
		Identifier identifier_;

}
