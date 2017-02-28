module beast.code.data.function_.function_;

import beast.code.data.toolkit;
import beast.code.ast.expr.expression;

abstract class Symbol_Function : Symbol {

public:
	/// Tries to match the function with given arguments
	FunctionMatch match( FunctionArgument[ ] args ) {
		assert( 0 );
	}

}

final class FunctionArgument {

public:
	this( AST_Expression ast ) {
		ast_ = ast;
	}

public:

private:
	AST_Expression ast_;
	DataEntity[ Symbol_Type ] cache_;

}

struct FunctionMatch {

public:
	MatchLevel matchLevel;

public:
	enum MatchLevel {
		noMatch, /// Function does not match the arguments at all
		fullMatch /// All types match etcetc
	}

}

final class FunctionParameter {

public: /// Type of the parameter; null = auto type
	Symbol_Type type;

	/// Implicit value of the parameter, can be null
	DataEntity defaultValue;

	/// Non-null for constant-value parameters - returns their value
	DataEntity fixedValue;

	/// If the parameter value is required at compile time
	bool isCtime;

	/// If the parameter is isVariadic
	bool isVariadic;

public:
	bool isAutoType( ) {
		return type is null;
	}

}
