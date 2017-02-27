module beast.code.data.var.variable;

import beast.code.data.toolkit;

abstract class Symbol_Variable : Symbol {

public:
	/// Variable data type
	abstract Symbol_Type dataType( );

}
