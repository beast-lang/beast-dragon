module beast.code.sym.type.staticclass;

import beast.code.sym.toolkit;
import beast.code.sym.type.class_;
import beast.code.data.toolkit;
import beast.code.data.entity.symnolrelated;

abstract class Symbol_StaticClassType : Symbol_ClassType {

public:
	this( Namespace parentNamespace ) {
		parentNamespace_ = parentNamespace;
		staticData_ = new StaticData;
	}

public:
	final override DeclType declarationType( ) {
		return DeclType.staticClass;
	}

	final override Namespace parentNamespace( ) {
		return parentNamespace_;
	}

public:
	final override DataEntity data( DataEntity parentInstance = null ) {
		return staticData_;
	}

private:
	Namespace parentNamespace_;
	StaticData staticData_;

private:
	final class StaticData : SymbolRelatedDataEntity {

	public:
		this( ) {
			super( null, this.outer );
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
