module beast.code.data.type.staticclass;

import beast.code.data.toolkit;
import beast.code.data.type.class_;

abstract class Symbol_StaticClassType : Symbol_ClassType {

public:
	this() {
		staticData_ = new Data;
	}

public:
	final override DeclType declarationType( ) {
		return DeclType.staticClass;
	}

public:
	final override DataEntity data( DataEntity parentInstance = null ) {
		return staticData_;
	}

private:
	Data staticData_;

private:
	final class Data : SymbolRelatedDataEntity {

	public:
		this( ) {
			super( this.outer );
		}

	public:
		override Symbol_Type dataType( ) {
			return coreLibrary.types.Type;
		}

		override bool isCtime( ) {
			return true;
		}

		override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			cb.build_staticMemoryAccess( this.outer.ctimeValue_ );
		}

		// TODO: resolve identifier

	}

}
