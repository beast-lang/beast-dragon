module beast.code.sym.var.static_;

import beast.code.sym.toolkit;
import beast.code.sym.var.variable;

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

private:
	Namespace parentNamespace_;
	StaticData staticData_;

private:
	final class StaticData : DataEntity {

	public:
		this( ) {
			// Static variables are in global scope
			super( null );
		}

	public:
		override Symbol_Type dataType( ) {
			return this.outer.dataType;
		}

		override bool isCtime( ) {
			return false;
		}

		override Identifier identifier( ) {
			return this.outer.identifier;
		}

		override string identificationString( ) {
			return this.outer.identificationString;
		}

	}

}
