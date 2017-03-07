module beast.corelib.types.bool_;

import beast.corelib.types.toolkit;

final class Symbol_Type_Bool : Symbol_StaticClassType {

	public:
		this( DataEntity parent ) {
			super( parent );

			namespace_ = new BootstrapNamespace( this );

			Symbol[ ] members;

			members ~= new Symbol_BootstrapMemberRuntimeFunction( "#operatorOr", this, this, //
					ExpandedFunctionParameter.bootstrap( this ), //
					( cb, scope_, params ) { //
						// Do nothing
					} );

			namespace_.initialize( members );
		}

	public:
		override Identifier identifier( ) {
			return Identifier.preobtained!"Bool";
		}

		override size_t instanceSize( ) {
			return 1;
		}

		override Namespace namespace( ) {
			return namespace_;
		}

	private:
		BootstrapNamespace namespace_;
}
