module beast.code.semantic.var.variable;

import beast.code.semantic.toolkit;

abstract class Symbol_Variable : Symbol {

public:
	/// Variable data type
	abstract Symbol_Type dataType();

}
