module beast.code.ast.node;

import beast.code.ast.toolkit;
import beast.code.symbol.symbol;

/// Base class for arr abstract syntax tree nodes
abstract class ASTNode {

public:
	/// Location of code corresponding with the AST node
	CodeLocation codeLocation;

	/// For semantic analysis, it is possible to link symbols to the AST nodes
	/// HOWEVER, this function can be called after EVERYTHING IS DONE
	Symbol relatedSymbol;

public:
	/// All nodes that are direct children of the current node; NOT IN CODE SOURCE ORDER
	abstract ASTNode[ ] subnodes( );

}
