module beast.code.sym.var.variable;

import beast.code.sym.toolkit;

abstract class Symbol_Variable : Symbol {

public:
	/// Variable data type
	abstract @property Symbol_Type dataType( );

}
