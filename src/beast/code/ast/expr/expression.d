module beast.code.ast.expr.expression;

import beast.code.ast.toolkit;
import beast.code.ast.expr.auto_;
import beast.code.ast.expr.vardecl;
import beast.code.memory.ptr;
import beast.code.memory.memorymgr;
import beast.code.data.scope_.root;
import beast.code.ast.expr.assign;
import std.typecons : Tuple;
import beast.code.ast.expr.parentcomma;

abstract class AST_Expression : AST_Statement {
	alias LowerLevelExpression = AST_AssignExpression;

	public:
		static bool canParse( ) {
			return LowerLevelExpression.canParse;
		}

		static AST_Expression parse( bool parseDeclarations = true ) {
			auto _gd = codeLocationGuard( );
			auto result = LowerLevelExpression.parse( );

			if ( parseDeclarations && result.isPrefixExpression && currentToken == Token.Type.identifier )
				return AST_VariableDeclarationExpression.parse( _gd, null, result );

			return result;
		}

	public:
		/// Returns if the expression is P1 or lower
		bool isPrefixExpression( ) {
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

		AST_ParentCommaExpression isParentCommaExpression( ) {
			return null;
		}

		Tuple!( AST_Expression, AST_ParentCommaExpression ) asNewRightExpression( ) {
			auto _gd = ErrorGuard( this );
			berror( E.syntaxError, "The 'new' expression has to end with '( args )'" );
			assert( 0 );
		}

	public:
		/// Builds semantic tree (no code is built) for this expression and returns data entity representing the result.
		/// inferType is used for type inferration and can be null (any result is then acceptable)
		/// The scope is used only for identifier lookup
		/// Can result in executing ctime code
		/// If errorOnInferrationFailure is false, returns null data entity if the expression cannot be built with given inferredType
		abstract Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true );

		/// Builds semantic tree (with inferration of iniferredType), checks if the overloadset returns anything
		/// The result DataEntity dataType can differ from infferedType!
		final DataEntity buildSemanticTree_singleInfer( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			Overloadset result = buildSemanticTree( inferredType, errorOnInferrationFailure );

			if ( !result.length && !errorOnInferrationFailure )
				return null;

			return result.single;
		}

		/// Builds semantic tree (with inferration of expectedType), checks if the overloadset returns anything and enforces the result to be of type expectedType
		final DataEntity buildSemanticTree_singleExpect( Symbol_Type expectedType, bool errorOnInferrationFailure = true ) {
			Overloadset result = buildSemanticTree( expectedType, errorOnInferrationFailure );

			if ( !result.length && !errorOnInferrationFailure )
				return null;

			DataEntity resultEntity = result.single_expectType( expectedType );

			assert( resultEntity.dataType is expectedType );
			return resultEntity;
		}

		/// Builds semantic tree, andchecks if the overloadset returns anything
		final DataEntity buildSemanticTree_single( bool errorOnInferrationFailure = true ) {
			Overloadset result = buildSemanticTree( null, errorOnInferrationFailure );

			if ( !result.length && !errorOnInferrationFailure )
				return null;

			return result.single;
		}

		override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb ) {
			auto _gd = ErrorGuard( codeLocation );

			cb.build_scope( ( cb ) { //
				buildSemanticTree_single( ).buildCode( cb );
			} );
		}

		final MemoryPtr ctExec( Symbol_Type expectedType ) {
			return buildSemanticTree_singleExpect( expectedType ).ctExec( );
		}

		/// Executes the expression in standalone scope and session, returing its value
		/// The scope the ctExec creates is never destroyed
		final MemoryPtr standaloneCtExec( Symbol_Type expectedType, DataEntity parent ) {
			const auto __gd = ErrorGuard( codeLocation );

			with ( memoryManager.session ) {
				auto _s = new RootDataScope( parent );
				auto _sgd = _s.scopeGuard;

				MemoryPtr result = ctExec( expectedType );

				_s.finish( );
				assert( _s.itemCount <= 1, "StandaloneCtExec scope has %s items".format( _s.itemCount ) );

				// No cleanup build - bulit variables remain (should be only one)
				return result;
			}

			assert( 0 );
		}

}
