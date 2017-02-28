module beast.code.data.function_.runtime;

import beast.code.data.toolkit;
import beast.code.data.function_.function_;

/// Runtime function = function without @ctime arguments (or expanded ones)
abstract class Symbol_RuntimeFunction : Symbol_Function {

public:
	abstract Symbol_Type returnType();

}