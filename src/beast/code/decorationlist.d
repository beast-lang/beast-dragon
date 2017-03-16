module beast.code.decorationlist;

import beast.code.toolkit;
import beast.code.ast.decorationlist;
import beast.code.ast.decl.variable;
import beast.code.ast.decl.function_;
import beast.code.ast.decoration;
import beast.code.data.decorator.decorator;

/// Class for working with decoration lists; it is used for gradually applying decorators on a symbol (context by context)
final class DecorationList {

	public:
		this( AST_DecorationList list, DataEntity context ) {
			import std.array : appender;

			assert( context, "null context" );

			context_ = context;

			// Group all decorations to an array
			{
				scope AST_DecorationList[ ] stack;
				while ( list ) {
					stack ~= list;
					list = list.parentDecorationList;
				}

				auto sink = appender!( Record[ ] )( );

				// We want the top level decorator list items first
				foreach_reverse ( it; stack )
					sink ~= it.list.map!( x => Record( x ) );

				list_ = sink.data;
			}
		}

	public:
		/// Applies all possible decorations in the variableDeclarationModifier context and removes them from the list
		void apply_variableDeclarationModifier( VariableDeclarationData var ) {
			standardDecoratorProcedure!"variableDeclarationModifier"( coreLibrary.module_.dataEntity, var );
		}

		/// Applies all possible decorations in the functionDeclarationModifier context and removes them from the list
		void apply_functionDeclarationModifier( FunctionDeclarationData var ) {
			standardDecoratorProcedure!"functionDeclarationModifier"( coreLibrary.module_.dataEntity, var );
		}

		Symbol_Type apply_typeWrapper( Symbol_Type originalType ) {
			// originalType is passed by reference
			standardDecoratorProcedure!"typeWrapper"( context_, originalType );
			return originalType;
		}

	public:
		/// Enforces that all decorators are resolved, otherwise reports an error
		void enforceAllResolved( ) {
			auto unresolvedList = list_.filter!( x => x.decorator is null );
			benforce( unresolvedList.empty, E.unresolvedDecorators, "Could not resolve decorators: %s".format( unresolvedList.map!( x => "'%s'".format( x.decoration.identifier.str ) ).joiner( ", " ) ) );
		}

	private:
		void standardDecoratorProcedure( string applyFunctionName, Args... )( DataEntity context, auto ref Args args ) {
			// Right decorators have higher priority
			foreach_reverse ( ref Record rec; list_ ) {
				// If the record has already resolved decorator, just try applying the decorator in the context
				if ( auto deco = rec.decorator ) {
					__traits( getMember, deco, "apply_" ~ applyFunctionName )( args );
					continue;
				}

				// Otherwise try resolving the decorator
				foreach ( decorator; context.recursivelyResolveIdentifier( rec.decoration.decoratorIdentifier ).filter_decoratorsOnly ) {
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
