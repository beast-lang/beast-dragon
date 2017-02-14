module beast.code.sym.var.static_;

import beast.code.sym.toolkit;
import beast.code.sym.var.variable;

/// User (programmer) defined variable
abstract class Symbol_StaticVariable : Symbol_Variable {

public:
	final override @property SymbolEnvironmentType envType( ) {
		return SymbolEnvironmentType.static_;
	}

}
