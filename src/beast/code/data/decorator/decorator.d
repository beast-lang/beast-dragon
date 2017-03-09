module beast.code.data.decorator.decorator;

import beast.code.data.toolkit;
import beast.code.ast.decl.variable;
import beast.code.ast.decl.function_;

/// Base class for all decorator types
abstract class Symbol_Decorator : Symbol {

	public:
		this( DataEntity parent ) {
			parent_ = parent;
			staticData_ = new Data;
		}

	public:
		final override DeclType declarationType( ) {
			return DeclType.decorator;
		}

	public:
		final override DataEntity dataEntity( DataEntity parentInstance = null ) {
			return staticData_;
		}

	public:
		/// Tries to apply in the variableDeclarationModifier context. Returns true if successful
		bool apply_variableDeclarationModifier( VariableDeclarationData data ) {
			return false;
		}

		/// Tries to apply in the functionDeclarationModifier context. Returns true if successful
		bool apply_functionDeclarationModifier( FunctionDeclarationData data ) {
			return false;
		}

		/// Attempts to apply the decorator in the typeDecorator context. Returns true if successfull.
		/// Type decorator takes one type and returns another
		bool apply_typeWrapper( ref Symbol_Type type ) {
			return false;
		}

	public:
		override void buildDefinitionsCode( CodeBuilder cb ) {
			// Do nothing
		}

	private:
		DataEntity parent_;
		DataEntity staticData_;

	private:
		final class Data : SymbolRelatedDataEntity {

			public:
				this( ) {
					super( this.outer );
				}

			public:
				override Symbol_Type dataType( ) {
					// TODO: decorator reflection
					return coreLibrary.type.Void;
				}

				override bool isCtime( ) {
					return true;
				}

				override DataEntity parent( ) {
					return this.outer.parent_;
				}

				override Symbol_Decorator isDecorator( ) {
					return this.outer;
				}

		}

}

enum DecorationContext {
	_noContext,

	// AST level contexts: (are applied before symbol creation)
	variableDeclarationModifier, /// For example @static

	// Symbol level contexts: (are applied on symbols)
}
