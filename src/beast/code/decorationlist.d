module beast.code.decorationlist;

import beast.code.toolkit;
import beast.code.ast.decoration;
import beast.code.ast.decorationlist;
import beast.code.sym.var.user;

/// Class for working with decoration lists; it is used for gradually applying decorators on a symbol (context by context)
final class DecorationList {

public:
	this( AST_DecorationList list ) {
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
	/// Applies all possible decorations in the variableModifier context and removes them from the list
	void apply_variableModifier( Symbol_UserVariable var ) {
		// Right decorators have higher priority
		foreach_reverse ( ref Record rec; list_ ) {
			// If the record has already resolved decorator, just try applying the decorator in the context
			if( rec.decorator ) {
				rec.decorator.apply_variableDeclarationModifier( var );
				continue;
			}

			// Otherwise try resolving the decorator
			// The only variableModifier decorators are in core library (maybe will change in future?)
			foreach ( decorator; coreLibrary.module_.resolveIdentifier( rec.decoration.decoratorIdentifier ).filterDecorators ) {
				if ( decorator.apply_variableDeclarationModifier( var ) ) {
					rec.decorator = decorator;
					break;
				}
			}
		}
	}

private:
	Record[ ] list_;

private:
	static struct Record {
		AST_Decoration decoration;
		/// Initially null, set when decoration is resolved
		Symbol_Decorator decorator;
	}

}
