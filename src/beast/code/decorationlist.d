module beast.code.decorationlist;

import beast.code.toolkit;
import beast.code.ast.decoration;
import beast.code.ast.decorationlist;
import beast.code.ast.decl.variable;

/// Class for working with decoration lists; it is used for gradually applying decorators on a symbol (context by context)
final class DecorationList {

public:
	this( AST_DecorationList list, DataEntity context ) {
		assert( context );

		context_ = context;

		// Group all decorations to an array
		{
			scope AST_DecorationList[ ] stack;
			while ( list ) {
				stack ~= list;
				list = list.parentDecorationList;
			}

			auto sink = list_.appender;

			// We want the top level decorator list items first
			foreach_reverse ( it; stack )
				sink ~= it.list.map!( x => Record( x ) );
		}
	}

public:
	/// Applies all possible decorations in the variableDeclarationModifier context and removes them from the list
	void apply_variableDeclarationModifier( VariableDeclarationData var, DataScope scope_ ) {
		standardDecoratorProcedure!"variableDeclarationModifier"( coreLibrary.module_.dataEntity, scope_, var );
	}

	/// Applies all possible decorations in the functionDeclarationModifier context and removes them from the list
	void apply_functionDeclarationModifier( FunctionDeclarationData var, DataScope scope_ ) {
		standardDecoratorProcedure!"functionDeclarationModifier"( coreLibrary.module_.dataEntity, scope_, var );
	}

	Symbol_Type apply_typeWrapper( Symbol_Type originalType, DataScope scope_ ) {
		// originalType is passed by reference
		standardDecoratorProcedure!"typeWrapper"( context_, scope_, originalType );
		return originalType;
	}

private:
	void standardDecoratorProcedure( string applyFunctionName, Args... )( DataEntity context, DataScope scope_, auto ref Args args ) {
		// Right decorators have higher priority
		foreach_reverse ( ref Record rec; list_ ) {
			// If the record has already resolved decorator, just try applying the decorator in the context
			if ( rec.decorator ) {
				auto deco = rec.decorator;
				__traits( getMember, deco, "apply_" ~ applyFunctionName )( args );
				continue;
			}

			// Otherwise try resolving the decorator
			foreach ( decorator; context.recursivelyResolveIdentifier( rec.decoration.decoratorIdentifier, scope_ ).filter_decoratorsOnly ) {
				// If the decorator is appliable in given context, mark the given decorator as resolved
				if ( __traits( getMember, decorator, "apply_" ~ applyFunctionName )( args ) ) {
					rec.decorator = decorator;
					break;
				}
			}
		}
	}

private:
	Record[ ] list_;
	DataEntity context_;

private:
	static struct Record {
		AST_Decoration decoration;
		/// Initially null, set when decoration is resolved
		Symbol_Decorator decorator;
	}

}
