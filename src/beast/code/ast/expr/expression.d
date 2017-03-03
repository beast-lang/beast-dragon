module beast.code.ast.expr.expression;

import beast.backend.ctime.codebuilder;
import beast.code.ast.expr.auto_;
import beast.code.ast.stmt.statement;
import beast.code.ast.toolkit;
import beast.code.data.scope_.local;
import beast.code.data.scope_.root;
import beast.code.memory.mgr;
import beast.code.ast.expr.vardecl;

abstract class AST_Expression : AST_Statement {

public:
	static bool canParse( ) {
		return AST_P1Expression.canParse;
	}

	static AST_Expression parse( bool parseDeclarations = true ) {
		auto _gd = codeLocationGuard( );
		auto result = AST_P1Expression.parse( );

		if ( parseDeclarations && result.isP1Expression && currentToken == Token.Type.identifier )
			return AST_VariableDeclarationExpression.parse( _gd, null, result );

		return result;
	}

public:
	/// Returns if the expression is P1 or lower
	bool isP1Expression( ) {
		return false;
	}

	/// Returns if the expression is auto (auto or auto? or auto ?! etc.)
	AST_AutoExpression isAutoExpression( ) {
		return null;
	}

	/// Returns if the expression is variable declaration
	AST_VariableDeclarationExpression isVariableDeclaration( ) {
		return null;
	}

public:
	/// Builds semantic tree (no code is built) for this expression and returns data entity representing the result.
	/// expectedType is used for type inferration and can be null (any result is then acceptable)
	/// The scope is used only for identifier lookup
	/// Can result in executing ctime code
	/// If errorOnInferrationFailure is false, returns null data entity if the expression cannot be built with given expectedType
	abstract Overloadset buildSemanticTree( Symbol_Type expectedType, DataScope scope_, bool errorOnInferrationFailure = true );

	final DataEntity buildSemanticTree_single( Symbol_Type expectedType, DataScope scope_, bool errorOnInferrationFailure = true ) {
		return buildSemanticTree( expectedType, scope_, errorOnInferrationFailure ).single_expectType( expectedType );
	}

	override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb, DataScope scope_ ) {
		buildSemanticTree_single( null, scope_ ).buildCode( cb, scope_ );
	}

	final MemoryPtr ctExec( Symbol_Type expectedType, DataScope scope_ ) {
		return buildSemanticTree_single( expectedType, scope_ ).ctExec( scope_ );
	}

	/// Executes the expression in standalone scope and session, returing its value
	/// The scope the ctExec creates is never destroyed
	final MemoryPtr standaloneCtExec( Symbol_Type expectedType, DataEntity parent ) {
		const auto _gd = ErrorGuard( this );

		with ( memoryManager.session ) {
			DataScope scope_ = new RootDataScope( parent );
			MemoryPtr result = ctExec( expectedType, scope_ );
			scope_.finish( );
			return result;
		}

		assert( 0 );
	}

}
