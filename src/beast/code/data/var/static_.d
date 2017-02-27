module beast.code.data.var.static_;

import beast.code.data.toolkit;
import beast.code.data.var.variable;

/// User (programmer) defined variable
abstract class Symbol_StaticVariable : Symbol_Variable {

public:
	this() {
		staticData_ = new Data;
	}

public:
	final override DeclType declarationType( ) {
		return DeclType.staticVariable;
	}

public:
	final override DataEntity data( DataEntity parentInstance = null ) {
		return staticData_;
	}

	abstract bool isCtime();

	/// Returns pointer to data of this variable
	abstract MemoryPtr dataPtr( );

private:
	Data staticData_;

private:
	final class Data : SymbolRelatedDataEntity {

	public:
		this( ) {
			// Static variables are in global scope
			super( this.outer );
		}

	public:
		override Symbol_Type dataType( ) {
			return this.outer.dataType;
		}

		override bool isCtime( ) {
			return this.outer.isCtime;
		}

	public:
		override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			cb.build_staticMemoryAccess( this.outer.dataPtr );
		}

	}

}
