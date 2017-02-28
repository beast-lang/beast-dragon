module beast.code.ast.expr.expression;

import beast.code.ast.toolkit;
import beast.code.memory.mgr;
import beast.code.data.scope_.root;
import beast.backend.ctime.codebuilder;
import beast.code.data.scope_.local;
import beast.code.ast.stmt.statement;

abstract class AST_Expression : AST_Statement {

public:
	static bool canParse( ) {
		return AST_P1Expression.canParse;
	}

	static AST_Expression parse( ) {
		return AST_P1Expression.parse( );
	}

public:
	/// Builds semantic tree (no code is built) for this expression and returns data entity representing the result.
	/// expectedType is used for type inferration and can be null (any result is then acceptable)
	/// The scope is used only for identifier lookup
	/// Can result in executing ctime code
	/// If errorOnFailure is false, returns null data entity if the expression cannot be built with given expectedType
	abstract DataEntity buildSemanticTree( Symbol_Type expectedType, DataScope scope_, bool errorOnFailure = true );

	override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb, DataScope scope_ ) {
		buildSemanticTree( null, scope_ ).buildCode( cb, scope_ );
	}

	/// Executes the expression in standalone scope and session, returing its value
	/// The scope the ctExec creates is never destroyed
	final MemoryPtr standaloneCtExec( Symbol_Type expectedType, DataEntity parent ) {
		with ( memoryManager.session ) {
			DataScope scope_ = new RootDataScope( parent );
			scope codeBuilder = new CodeBuilder_Ctime;
			this.buildSemanticTree( expectedType, scope_ ).buildCode( codeBuilder, scope_ );

			scope_.finish();
			return codeBuilder.result;
		}

		assert( 0 );
	}

}
