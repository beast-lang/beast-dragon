module beast.code.semantic.var.tmplocal;

import beast.code.semantic.toolkit;
import beast.code.semantic.scope_.local;
import beast.code.semantic.var.local;

final class DataEntity_TmpLocalVariable : DataEntity_LocalVariable {

public:
	this(Symbol_Type dataType, string desc = "#tmpLocal#") {
		super(dataType);
		desc_ = desc;
	}

public:
	override AST_Node ast() {
		return null;
	}

	override string identification() {
		return desc_;
	}

private:
	/// Desc is something like identifier, but only for reporting purposes
	string desc_;

}
