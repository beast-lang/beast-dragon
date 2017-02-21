module beast.code.sym.var.static_;

import beast.code.sym.toolkit;
import beast.code.sym.var.variable;
import beast.code.data.toolkit;
import beast.code.data.entity.symnolrelated;

/// User (programmer) defined variable
abstract class Symbol_StaticVariable : Symbol_Variable {

public:
	this( Namespace parentNamespace ) {
		parentNamespace_ = parentNamespace;
		staticData_ = new StaticData;
	}

public:
	final override DeclType declarationType( ) {
		return DeclType.staticVariable;
	}

	final override Namespace parentNamespace( ) {
		return parentNamespace_;
	}

public:
	final override DataEntity data( DataEntity parentInstance = null ) {
		return staticData_;
	}

	/// Returns pointer to data of this variable
	abstract MemoryPtr dataPtr( );

private:
	Namespace parentNamespace_;
	StaticData staticData_;

private:
	final class StaticData : SymbolRelatedDataEntity {

	public:
		this( ) {
			// Static variables are in global scope
			super( null, this.outer );
		}

	public:
		override Symbol_Type dataType( ) {
			return this.outer.dataType;
		}

		override bool isCtime( ) {
			return false;
		}

	public:
		override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			cb.build_staticMemoryAccess( this.outer.dataPtr );
		}

	}

}
