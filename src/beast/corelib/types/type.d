module beast.corelib.types.type;

import beast.code.data.toolkit;
import beast.code.data.type.staticclass;
import beast.code.data.codenamespace.bootstrap;

/// Type 'Type' -- typeof all classes etc.
/// The root of all good and evil in Beast.
/// Here be dragons
final class Symbol_Type_Type : Symbol_StaticClassType {

public:
	this( DataEntity parent ) {
		super( parent );
		
		namespace_ = new BootstrapNamespace( this );
		namespace_.initialize( null );
	}

public:
	override Identifier identifier( ) {
		return Identifier.preobtained!"Type";
	}

	override size_t instanceSize( ) {
		return size_t.sizeof;
	}

	override Namespace namespace( ) {
		return namespace_;
	}
	
private:
	BootstrapNamespace namespace_;

}
