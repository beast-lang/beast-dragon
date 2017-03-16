module beast.code.data.type.enum_;

import beast.code.data.toolkit;
import beast.code.data.type.stcclass;
import beast.code.data.util.reinterpret;

abstract class Symbol_Enum : Symbol_Type {

	public:
		this( DataEntity parent, Symbol_StaticClass baseClass ) {
			staticData_ = new Data;
			parent_ = parent;
			baseClass_ = baseClass;
		}

	public:
		final override DeclType declarationType( ) {
			return DeclType.enum_;
		}

		/// Class the enum is based on
		Symbol_StaticClass baseClass( ) {
			return baseClass_;
		}

	public:
		final override DataEntity dataEntity( DataEntity parentInstance = null ) {
			return staticData_;
		}

	protected:
		override Overloadset _resolveIdentifier_mid( Identifier id, DataEntity instance ) {
			if( instance )
				return baseClass_.resolveIdentifier( id, new DataEntity_ReinterpretCast( instance, baseClass_ ) );

			return baseClass_.resolveIdentifier( id, null );
		}

	protected:
		Symbol_StaticClass baseClass_;

	private:
		DataEntity staticData_;
		DataEntity parent_;

	private:
		final class Data : super.Data {

			public:
				override DataEntity parent( ) {
					return parent_;
				}

		}

}
