module beast.code.sym.var.type;

import beast.code.toolkit;
import beast.code.sym.var.static_;

/// Type variable
final class Symbol_Variable_Type : Symbol_StaticVariable {

public:
	this( BeastType type ) {
		type_ = type;

		with ( memoryManager.session ) {
			ctimeData_ = memoryManager.alloc( size_t.sizeof );
			ctimeData_.writePrimitive!size_t( type.typeUID );
		}
	}

public:
	override @property Identifier identifier( ) {
		return type_.identifier;
	}

	override @property Identifier baseName() {
		return type_.baseName;
	}

public:
	override @property BeastType type( ) {
		return coreLibrary.types.Type;
	}

	override @property bool isCtime( ) {
		return true;
	}

	override @property MemoryPtr ctimeData( MemoryPtr contextPointer ) {
		return ctimeData_;
	}

private:
	MemoryPtr ctimeData_;
	BeastType type_;

}
