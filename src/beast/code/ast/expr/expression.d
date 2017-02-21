module beast.code.ast.expr.expression;

import beast.code.ast.toolkit;
import beast.code.namespace.namespace;
import beast.code.memory.mgr;
import beast.code.data.scope_.root;
import beast.backend.ctime.codebuilder;

abstract class AST_Expression : AST_Node {

public:
	static bool canParse( ) {
		return AST_P1Expression.canParse;
	}

	static AST_Expression parse( ) {
		return AST_P1Expression.parse( );
	}

public:
	/// Builds semantic tree (no code is built) for this expression and returns data entity representing the result.
	/// expectedType is used for type inferration and can be null
	/// The scope is used only for identifier lookup
	abstract DataEntity buildTree( Symbol_Type expectedType, DataScope scope_ );

	/// Executes the expression in standalone scope and session, returing its value
	final MemoryPtr standaloneCtExec( Symbol_Type expectedType, DataEntity parent ) {
		with ( memoryManager.session ) {
			RootDataScope scope_ = new RootDataScope( parent );
			CodeBuilder_Ctime codeBuilder = new CodeBuilder_Ctime;
			buildTree( expectedType, scope_ ).buildCode( codeBuilder, scope_ );
			return codeBuilder.result;
		}
	}

}
