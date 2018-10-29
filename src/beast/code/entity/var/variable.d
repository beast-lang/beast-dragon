module beast.code.entity.var.variable;

import beast.code.entity.toolkit;

abstract class Symbol_Variable : Symbol {

public:
	/// Variable data type
	abstract Symbol_Type dataType();

}
