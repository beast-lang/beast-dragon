module beast.code.ast.expr.expression;

import beast.code.ast.toolkit;

abstract class AST_Expression : AST_Node {

public:
	static bool canParse( ) {
		return AST_P1Expression.canParse;
	}

	static AST_Expression parse( ) {
		return AST_P1Expression.parse( );
	}

public:
	/// Builds code for this expression using given codebuilder and returns symbol representing the result7
	/// expectedType is used for type inferration and can be null
	//abstract DataEntity build( CodeBuilder cb, Symbol_Type expectedType, DataScope scope_ );

}
