module beast.code.decorationlist;

import beast.code.toolkit;
import beast.code.ast.decorationlist;
import beast.code.ast.decl.variable;
import beast.code.ast.decl.function_;
import beast.code.ast.decoration;
import beast.code.data.decorator.decorator;
import beast.code.ast.decl.class_;
import beast.code.ast.expr.decorated;
import beast.code.data.idcontainer;
import beast.code.ast.decl.env;
import beast.code.ast.stmt.statement;
import beast.code.data.function_.paramlist;
import beast.code.data.function_.param;

/// Class for working with decoration lists; it is used for gradually applying decorators on a symbol (context by context)
final class DecorationList {

	public:
		this( AST_DecorationList list ) {
			import std.array : appender;

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
			standardDecoratorProcedure!"variableDeclarationModifier"( currentScope, var );
		}

		/// Applies all possible decorations in the functionDeclarationModifier context and removes them from the list
		void apply_functionDeclarationModifier( FunctionDeclarationData var ) {
			standardDecoratorProcedure!"functionDeclarationModifier"( currentScope, var );
		}

		/// Applies all possible decorations in the functionParameterModifier context and removes them from the list
		void apply_functionParameterModifier( FunctionParameterDecorationData data ) {
			standardDecoratorProcedure!"functionParameterModifier"( currentScope, data );
		}

		/// Applies all possible decorations in the classDeclarationModifier context and removes them from the list
		void apply_classDeclarationModifier( ClassDeclarationData var ) {
			standardDecoratorProcedure!"classDeclarationModifier"( currentScope, var );
		}

		Symbol_Type apply_typeWrapper( Symbol_Type originalType ) {
			// originalType is passed by reference
			standardDecoratorProcedure!"typeWrapper"( currentScope, originalType );
			return originalType;
		}

		void apply_expressionDecorator( ExpressionDecorationData data ) {
			standardDecoratorProcedure!"expressionDecorator"( currentScope, data );
		}

		void apply_statementDecorator( StatementDecorationData data ) {
			standardDecoratorProcedure!"statementDecorator"( currentScope, data );
		}

	public:
		/// Enforces that all decorators are resolved, otherwise reports an error
		void enforceAllResolved( ) {
			auto unresolvedList = list_.filter!( x => x.decorator is null );
			benforce( unresolvedList.empty, E.unresolvedDecorators, "Could not resolve decorators: %s".format( unresolvedList.map!( x => "'%s'".format( x.decoration.identifier.str ) ).joiner( ", " ) ) );
		}

	private:
		void standardDecoratorProcedure( string applyFunctionName, Args... )( IDContainer context, auto ref Args args ) {
			// Right decorators have higher priority
			foreach_reverse ( ref Record rec; list_ ) {
				// If the record has already resolved decorator, just try applying the decorator in the context
				if ( auto deco = rec.decorator ) {
					__traits( getMember, deco, "apply_" ~ applyFunctionName )( args );
					continue;
				}

				// Otherwise try resolving the decorator
				foreach ( decorator; context.tryRecursivelyResolveIdentifier( rec.decoration.decoratorIdentifier ).filter_decoratorsOnly ) {
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

	private:
		static struct Record {
			AST_Decoration decoration;
			/// Initially null, set when decoration is resolved
			Symbol_Decorator decorator;
		}

}
